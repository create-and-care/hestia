module VisualCheck
  # Turns the app's route set into a flat list of navigable GET URLs for a
  # given household/user, filling in dynamic segments (:id, :pet_id, ...)
  # from that household's own records. A route whose segment has no matching
  # record (most of them, when `household` is a freshly-created empty one)
  # is reported as skipped with a reason rather than raising — that's
  # expected, not a bug: it's exactly how the "-empty" pass ends up covering
  # only index/new/singleton screens.
  class RouteResolver
    Resolved = Struct.new(:name, :controller, :action, :url, :requires_auth, keyword_init: true)
    Skipped = Struct.new(:name, :controller, :action, :path, :reason, keyword_init: true)

    EXCLUDED_PATH_PREFIXES = %w[/api /jobs /rails /assets /cable /up].freeze
    PUBLIC_CONTROLLERS = %w[sessions registrations passwords].freeze

    # [controller, action] pairs that resolve fine but aren't a standalone
    # screen worth measuring/capturing.
    EXCLUDED_ACTIONS = {
      %w[external_calendar_connections connect] => "starts a real external OAuth redirect (Google/Microsoft) — can't be captured headless",
      %w[external_calendar_connections callback] => "OAuth callback — requires a live provider round-trip, not directly navigable",
      %w[documents preview] => "turbo-frame fragment (layout: false) — not a standalone screen, embedded via turbo-frame in documents#index",
      %w[turbo/native/navigation recede] => "Turbo Native bridge route (iOS/Android wrapper only) — not a browser-navigable screen",
      %w[turbo/native/navigation resume] => "Turbo Native bridge route (iOS/Android wrapper only) — not a browser-navigable screen",
      %w[turbo/native/navigation refresh] => "Turbo Native bridge route (iOS/Android wrapper only) — not a browser-navigable screen"
    }.freeze

    # Modules that hang off the signed-in user rather than the household
    # (cross-household social features, per-user wellbeing/private data).
    USER_SCOPED_CONTROLLERS = %w[circles workout_templates weight_entries workout_entries
                                  notifications external_calendar_connections].freeze

    # Resolves the leaf record for a controller directly, bypassing the
    # naive "association named after the controller, on the current scope"
    # guess — either because the controller resolves to the scope itself
    # (households#show), or because the route is declared top-level but the
    # model only actually hangs off a nested association (budget_entries
    # lives on BudgetCategory, not Household, even though the route has no
    # :budget_category_id segment).
    SCOPE_OVERRIDES = {
      "households" => ->(household, _user) { household },
      "budget_entries" => ->(household, _user) { household.budget_categories.detect { |c| c.budget_entries.any? }&.budget_entries&.first }
    }.freeze

    def initialize(household:, user:)
      @household = household
      @user = user
    end

    def resolve
      Rails.application.routes.routes.filter_map { |route| build(route) }
    end

    private
      def build(route)
        return nil if route.internal
        return nil unless route.verb == "GET"

        path = route.path.spec.to_s.sub(/\(\.:format\)\z/, "")
        return nil if excluded_path?(path)

        defaults = route.defaults
        controller = defaults[:controller]
        action = defaults[:action]
        return nil if controller.nil? # mounted rack app (e.g. Mission Control), no controller/action to introspect

        name = route.name || "#{controller.tr('/', '_')}_#{action}"

        if (reason = EXCLUDED_ACTIONS[[ controller, action ]])
          return Skipped.new(name: name, controller: controller, action: action, path: path, reason: reason)
        end

        if controller == "design_system" && action == "component"
          entry = DesignSystemRegistry.all.first
          return Skipped.new(name: name, controller: controller, action: action, path: path, reason: "no design system registry entries") unless entry
          return resolved(name, controller, action, path.sub(":id", entry.slug))
        end

        resolved_path, skip_reason = resolve_segments(path, controller)
        return Skipped.new(name: name, controller: controller, action: action, path: path, reason: skip_reason) if skip_reason

        resolved(name, controller, action, resolved_path)
      end

      def resolved(name, controller, action, url)
        Resolved.new(name: name, controller: controller, action: action, url: url,
          requires_auth: !PUBLIC_CONTROLLERS.include?(controller))
      end

      def excluded_path?(path)
        EXCLUDED_PATH_PREFIXES.any? { |prefix| path == prefix || path.start_with?("#{prefix}/") }
      end

      # Walks the path's dynamic segments left to right, descending from
      # `household` (or `user`, for the handful of user-scoped modules) one
      # association at a time — a leading "*_id" segment names its own
      # resource (Rails' nested-route convention), the trailing "id" (or a
      # differently-named param like ":token") names the controller's own
      # resource on whatever scope was reached so far.
      def resolve_segments(path, controller)
        segments = path.scan(/:(\w+)/).flatten
        return [ path, nil ] if segments.empty?

        scope = USER_SCOPED_CONTROLLERS.include?(controller) ? @user : @household
        resolved_path = path.dup

        segments.each do |segment|
          leaf = segment == "id"

          record = if leaf && SCOPE_OVERRIDES.key?(controller)
            SCOPE_OVERRIDES[controller].call(@household, @user)
          else
            resource_key = leaf ? controller.split("/").last : segment.delete_suffix("_id").pluralize
            fetch(scope, resource_key)
          end
          return [ nil, "no record available to resolve :#{segment}" ] if record.nil?

          resolved_path = resolved_path.sub(":#{segment}", record.to_param.to_s)
          scope = record
        end

        [ resolved_path, nil ]
      end

      def fetch(scope, resource_key)
        return nil unless scope.respond_to?(resource_key)

        assoc = scope.public_send(resource_key)
        case assoc
        when ActiveRecord::Relation, Array then assoc.first
        when ActiveRecord::Base then assoc
        else nil
        end
      rescue NoMethodError
        nil
      end
  end
end

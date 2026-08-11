require "socket"
require "open3"

module VisualCheck
  # Boots a real Puma server against the already-loaded Rails app (same
  # process, same DB connection — no separate `rails server` needed), makes
  # sure a realistically-seeded household and a freshly-empty one both exist,
  # hands the resolved route list to the Puppeteer driver, and turns its
  # results into report.md / routes.txt.
  class Runner
    PORT = ENV.fetch("VISUAL_CHECK_PORT", 3099).to_i
    VIEWPORTS = [ 390, 1440 ].freeze
    THEMES = %w[light dark].freeze
    DEMO_PASSWORD = "password123" # matches DemoData::Seeder::DEMO_USERS
    EMPTY_USER_EMAIL = "visual-empty@hestia.local"
    EMPTY_USER_PASSWORD = "password123"
    EMPTY_HOUSEHOLD_NAME = "Foyer Vide (visual check)"

    def initialize(mode:)
      @mode = mode # :capture or :assert
      @out_dir = Rails.root.join("tmp/visual")
    end

    def call
      abort "visual:check refuses to run outside development (current env: #{Rails.env})." unless Rails.env.development?

      FileUtils.mkdir_p(@out_dir)
      FileUtils.mkdir_p(@out_dir.join("shots")) if @mode == :capture
      Bullet.enable = false if defined?(Bullet) # keep the footer badge out of screenshots/measurements

      demo_household, demo_user = ensure_demo_household!
      empty_household, empty_user = ensure_empty_household!

      launcher = boot_server!

      begin
        manifest_path = build_manifest(demo_household, demo_user, empty_household, empty_user)
        run_node!(manifest_path)
        results = JSON.parse(File.read(@out_dir.join("results.json")))
        ReportBuilder.new(out_dir: @out_dir, results: results, route_skips: @route_skips, covered_routes: @covered_routes).call
      ensure
        launcher.stop
        File.delete(@out_dir.join(".manifest.json")) if File.exist?(@out_dir.join(".manifest.json"))
        File.delete(@out_dir.join("results.json")) if File.exist?(@out_dir.join("results.json"))
      end

      violation_count = results && results["violations"].size
      if @mode == :assert && violation_count.to_i > 0
        abort "visual:check[assert] — #{violation_count} violation(s). See tmp/visual/report.md."
      end

      puts "visual:check done — see tmp/visual/report.md and tmp/visual/routes.txt" + (@mode == :capture ? " (screenshots in tmp/visual/shots/)" : "")
    end

    private
      def ensure_demo_household!
        user = User.find_by(email_address: DemoData::Seeder::DEMO_USERS.first[:email_address])
        household = user&.households&.first
        return [ household, user ] if household

        household = DemoData::Seeder.call
        [ household, household.users.first ]
      end

      def ensure_empty_household!
        user = User.find_by(email_address: EMPTY_USER_EMAIL)
        household = user&.households&.first
        return [ household, user ] if household

        user ||= User.create!(email_address: EMPTY_USER_EMAIL, password: EMPTY_USER_PASSWORD, name: "Foyer Vide", locale: "fr")
        household = Household.create!(name: EMPTY_HOUSEHOLD_NAME, time_zone: "Paris", holiday_country: "FR")
        household.memberships.create!(user: user, role: "admin")
        [ household, user ]
      end

      def boot_server!
        require "puma"
        require "puma/configuration"
        require "puma/launcher"
        require "puma/log_writer"

        config = Puma::Configuration.new do |c|
          c.app Rails.application
          c.bind "tcp://127.0.0.1:#{PORT}"
          c.workers 0
          c.threads 1, 5
          c.silence_single_worker_warning
        end
        sink = File.open(File::NULL, "w")
        launcher = Puma::Launcher.new(config, log_writer: Puma::LogWriter.new(sink, sink))
        Thread.new { launcher.run }
        wait_for_port!
        launcher
      end

      def wait_for_port!(timeout: 15)
        deadline = Time.now + timeout
        begin
          TCPSocket.new("127.0.0.1", PORT).close
        rescue Errno::ECONNREFUSED, Errno::ETIMEDOUT
          raise "visual:check server did not start within #{timeout}s" if Time.now > deadline
          sleep 0.2
          retry
        end
      end

      def build_manifest(demo_household, demo_user, empty_household, empty_user)
        seeded_resolved = RouteResolver.new(household: demo_household, user: demo_user).resolve
        empty_resolved = RouteResolver.new(household: empty_household, user: empty_user).resolve

        @route_skips = []
        seeded_resolved.each { |r| @route_skips << skip_row("seeded", r) if r.is_a?(RouteResolver::Skipped) }
        empty_resolved.each { |r| @route_skips << skip_row("empty", r) if r.is_a?(RouteResolver::Skipped) }

        public_routes = seeded_resolved.select { |r| r.is_a?(RouteResolver::Resolved) && !r.requires_auth }
        seeded_routes = seeded_resolved.select { |r| r.is_a?(RouteResolver::Resolved) && r.requires_auth }
        empty_routes = empty_resolved.select { |r| r.is_a?(RouteResolver::Resolved) && r.requires_auth }

        @covered_routes =
          public_routes.map { |r| covered_row("public", r) } +
          seeded_routes.map { |r| covered_row("seeded", r) } +
          empty_routes.map { |r| covered_row("empty", r) }

        manifest = {
          baseUrl: "http://127.0.0.1:#{PORT}",
          mode: @mode.to_s,
          outDir: @out_dir.to_s,
          viewports: VIEWPORTS,
          themes: THEMES,
          passes: [
            { key: "public", auth: nil, routes: as_manifest(public_routes) },
            { key: "seeded", auth: { email: demo_user.email_address, password: DEMO_PASSWORD }, routes: as_manifest(seeded_routes) },
            { key: "empty", auth: { email: empty_user.email_address, password: EMPTY_USER_PASSWORD }, routes: as_manifest(empty_routes) }
          ]
        }

        path = @out_dir.join(".manifest.json")
        File.write(path, JSON.generate(manifest))
        path
      end

      def as_manifest(routes)
        routes.map { |r| { name: r.name, controller: r.controller, action: r.action, url: r.url } }
      end

      def skip_row(pass, skipped)
        { pass: pass, name: skipped.name, controller: skipped.controller, action: skipped.action, path: skipped.path, reason: skipped.reason }
      end

      def covered_row(pass, resolved)
        { pass: pass, name: resolved.name, controller: resolved.controller, action: resolved.action, url: resolved.url }
      end

      def run_node!(manifest_path)
        stdout, stderr, status = Open3.capture3(
          { "NODE_ENV" => "development" }, "node", "script/visual_check/run.mjs", manifest_path.to_s,
          chdir: Rails.root.to_s
        )
        puts stdout
        warn stderr unless stderr.strip.empty?
        abort "visual:check — Puppeteer driver failed (exit #{status.exitstatus})" unless status.success?
      end
  end
end

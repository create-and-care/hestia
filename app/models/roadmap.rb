# Progress by phase (Spec §18) and list of planned improvements, derived from
# the application analysis. Static data versioned with the code, similar to
# the Spec and Implementation Plan that they summarize. Rendered both in the
# "Roadmap" tab of household settings and on the standalone /roadmap page
# (reachable without an active household — see RoadmapController).
#
# Text lives in config/locales/{en,fr}/roadmap.yml, keyed by the slug below;
# only structural data (status, emoji, ordering) stays in Ruby.
module Roadmap
  PHASE_SLUGS = %w[
    foundation priority_modules satellite_modules richer_logic architecture_deviations
    reminders external_integrations api mobile governance marketing_site hestai
  ].freeze

  PHASE_STATUSES = {
    "foundation" => :done, "priority_modules" => :done, "satellite_modules" => :done,
    "richer_logic" => :done, "architecture_deviations" => :done, "reminders" => :done,
    "external_integrations" => :done, "api" => :done, "mobile" => :partial,
    "governance" => :done, "marketing_site" => :todo, "hestai" => :todo
  }.freeze

  IMPROVEMENT_SLUGS_AND_EMOJIS = {
    "dashboard" => "🧭", "security" => "🔐", "reliability" => "🧪", "functional_gaps" => "🧩",
    "api_mobile" => "📡", "i18n_a11y" => "🌍", "governance_docs" => "📚", "hestai" => "🤖"
  }.freeze

  def self.phases
    PHASE_SLUGS.map do |slug|
      {
        name: I18n.t("roadmap.phases.#{slug}.name"),
        detail: I18n.t("roadmap.phases.#{slug}.detail"),
        status: PHASE_STATUSES.fetch(slug)
      }
    end
  end

  def self.improvements
    IMPROVEMENT_SLUGS_AND_EMOJIS.map do |slug, emoji|
      {
        category: I18n.t("roadmap.improvements.#{slug}.category"),
        emoji: emoji,
        items: I18n.t("roadmap.improvements.#{slug}.items")
      }
    end
  end
end

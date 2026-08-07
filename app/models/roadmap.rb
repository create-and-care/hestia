# A chronological timeline of the project, from 2026-06-25 to
# today, plus what's next. Static data versioned with the code — the
# project's single source of truth for progress, replacing the separate
# Specification/Implementation Plan documents this project started from
# (deleted once their content was fully absorbed here). Rendered both on
# the standalone /roadmap page (reachable without an active household —
# see RoadmapController) and the "Roadmap" tab of household settings.
#
# Text lives in config/locales/{en,fr}/roadmap.yml, keyed by the slug
# below; only structural data (date, icon, ordering) stays in Ruby. A
# milestone with no date is upcoming work with no committed date yet.
# Within that upcoming block the order is roughly cost-ascending: what
# only needs wiring first, what needs a decision before a line of code is
# written (health_records) or a measurement before it is worth writing at
# all (scaling_thresholds) last.
#
# This list stays in chronological order — oldest shipped work first. The
# view is what reads it back to front (upcoming block first, then shipped
# newest-first); keeping the data chronological is what lets the dates
# below stay in an order a human can check.
#
# Shipped milestones are written as release notes: what a household can
# now do, not how it was built. The implementation detail belongs in
# CHANGELOG.md, which is versioned and already carries it.
module Roadmap
  MILESTONE_SLUGS = %w[
    foundation design_system wave_2a wave_2b wave_2c wave_2d pdf_export_reordering
    reminders_notifications external_integrations_v1 reference_catalogs
    api_and_mobile_skeleton governance i18n reliability_quality
    external_calendar_sync_real api_v1_full navigation_settings recipe_catalog
    visual_polish_icons ui_migration_a11y global_search
    refinement_wave_day1 refinement_wave_day2a refinement_wave_day2b
    refinement_wave_day3a refinement_wave_day3b
    public_route_hardening security_performance_hardening
    design_system_measured pwa i18n_guardrails
    wired_patterns account_privacy household_activity_export
    tasks_and_recurrence cooking_and_shopping
    reference_catalog_growth shared_link_controls household_logistics
    notifications_automation first_run_experience personalization health_records
    marketing_docs scaling_thresholds mobile_parity
    cross_household_recipes hestai
  ].freeze

  MILESTONE_DATES = {
    "foundation" => Date.new(2026, 6, 25),
    "design_system" => Date.new(2026, 6, 26),
    "wave_2a" => Date.new(2026, 7, 2),
    "wave_2b" => Date.new(2026, 7, 2),
    "wave_2c" => Date.new(2026, 7, 2),
    "wave_2d" => Date.new(2026, 7, 2),
    "pdf_export_reordering" => Date.new(2026, 7, 2),
    "reminders_notifications" => Date.new(2026, 7, 5),
    "external_integrations_v1" => Date.new(2026, 7, 5),
    "reference_catalogs" => Date.new(2026, 7, 5),
    "api_and_mobile_skeleton" => Date.new(2026, 7, 5),
    "governance" => Date.new(2026, 7, 5),
    "i18n" => Date.new(2026, 7, 6),
    "reliability_quality" => Date.new(2026, 7, 6),
    "external_calendar_sync_real" => Date.new(2026, 7, 6),
    "api_v1_full" => Date.new(2026, 7, 6),
    "navigation_settings" => Date.new(2026, 7, 7),
    "recipe_catalog" => Date.new(2026, 7, 8),
    "visual_polish_icons" => Date.new(2026, 7, 8),
    "ui_migration_a11y" => Date.new(2026, 7, 11),
    "global_search" => Date.new(2026, 7, 11),
    "refinement_wave_day1" => Date.new(2026, 7, 17),
    "refinement_wave_day2a" => Date.new(2026, 7, 18),
    "refinement_wave_day2b" => Date.new(2026, 7, 18),
    "refinement_wave_day3a" => Date.new(2026, 7, 19),
    "refinement_wave_day3b" => Date.new(2026, 7, 19),
    "public_route_hardening" => Date.new(2026, 8, 7),
    "security_performance_hardening" => Date.new(2026, 8, 7),
    "design_system_measured" => Date.new(2026, 8, 7),
    "pwa" => Date.new(2026, 8, 7),
    "i18n_guardrails" => Date.new(2026, 8, 7)
  }.freeze

  MILESTONE_STATUSES = MILESTONE_SLUGS.index_with { |slug| MILESTONE_DATES.key?(slug) ? :done : :upcoming }.freeze

  MILESTONE_ICONS = {
    "foundation" => "house", "design_system" => "layout-grid", "wave_2a" => "package",
    "wave_2b" => "package", "wave_2c" => "package", "wave_2d" => "triangle-alert",
    "pdf_export_reordering" => "file-text", "reminders_notifications" => "bell",
    "external_integrations_v1" => "link", "reference_catalogs" => "book-open",
    "api_and_mobile_skeleton" => "smartphone", "governance" => "scale", "i18n" => "map",
    "reliability_quality" => "square-check", "external_calendar_sync_real" => "refresh-cw",
    "api_v1_full" => "list", "navigation_settings" => "settings", "recipe_catalog" => "chef-hat",
    "visual_polish_icons" => "star", "ui_migration_a11y" => "puzzle", "global_search" => "search",
    "refinement_wave_day1" => "package", "refinement_wave_day2a" => "package",
    "refinement_wave_day2b" => "package", "refinement_wave_day3a" => "package",
    "refinement_wave_day3b" => "wrench",
    "account_privacy" => "trash-2", "household_activity_export" => "trending-up",
    "public_route_hardening" => "triangle-alert", "security_performance_hardening" => "wrench",
    "design_system_measured" => "layout-grid", "i18n_guardrails" => "info",
    "shared_link_controls" => "link", "household_logistics" => "sofa",
    "reference_catalog_growth" => "sprout",
    "wired_patterns" => "puzzle", "tasks_and_recurrence" => "list-checks",
    "cooking_and_shopping" => "utensils", "notifications_automation" => "bell",
    "first_run_experience" => "sun", "personalization" => "droplet",
    "health_records" => "heart-pulse", "scaling_thresholds" => "trending-up",
    "pwa" => "smartphone", "marketing_docs" => "map-pin", "mobile_parity" => "smartphone",
    "cross_household_recipes" => "handshake", "hestai" => "message-circle"
  }.freeze

  def self.milestones
    MILESTONE_SLUGS.map do |slug|
      {
        slug: slug,
        date: MILESTONE_DATES[slug],
        status: MILESTONE_STATUSES.fetch(slug),
        icon: MILESTONE_ICONS.fetch(slug),
        title: I18n.t("roadmap.milestones.#{slug}.title"),
        items: I18n.t("roadmap.milestones.#{slug}.items")
      }
    end
  end
end

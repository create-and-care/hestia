module WasteHelper
  # Lucide (https://lucide.dev) icon names, rendered via IconHelper#lucide_icon.
  ICONS = {
    "ordures" => "trash-2", "recyclage" => "recycle", "verre" => "wine", "compost" => "sprout", "encombrants" => "sofa"
  }.freeze

  # Ui::BadgeComponent variants (semantic tokens, correctly adapted to dark mode) instead of
  # hand-picked Tailwind color literals that don't shift under .dark.
  BADGE_VARIANTS = {
    "ordures" => :secondary,
    "recyclage" => :warning,
    "verre" => :success,
    "compost" => :urgent,
    "encombrants" => :default
  }.freeze

  WEEKDAY_KEYS = %w[sunday monday tuesday wednesday thursday friday saturday].freeze

  def waste_type_label(type) = t("waste.types.#{type}", default: type)
  def waste_type_icon(type) = lucide_icon(ICONS.fetch(type, "trash-2"), css_class: "size-3.5")
  def waste_type_badge_variant(type) = BADGE_VARIANTS.fetch(type, :secondary)
  def waste_type_options = WasteCollectionSeries::TYPES.map { |type| [ waste_type_label(type), type ] }
  def weekday_label(index) = t("waste.weekdays.#{WEEKDAY_KEYS.fetch(index, index.to_s)}", default: index.to_s)
  def weekday_options = (0..6).map { |index| [ weekday_label(index), index ] }
end

module WasteHelper
  # Lucide (https://lucide.dev) icon names, rendered via IconHelper#lucide_icon.
  ICONS = {
    "ordures" => "trash-2", "recyclage" => "recycle", "verre" => "wine", "compost" => "sprout", "encombrants" => "sofa"
  }.freeze

  BADGE_CLASSES = {
    "ordures" => "bg-gray-200 text-gray-800",
    "recyclage" => "bg-yellow-100 text-yellow-800",
    "verre" => "bg-green-100 text-green-800",
    "compost" => "bg-amber-100 text-amber-800",
    "encombrants" => "bg-blue-100 text-blue-800"
  }.freeze

  WEEKDAY_KEYS = %w[sunday monday tuesday wednesday thursday friday saturday].freeze

  def waste_type_label(type) = t("waste.types.#{type}", default: type)
  def waste_type_icon(type) = lucide_icon(ICONS.fetch(type, "trash-2"), css_class: "size-3.5")
  def waste_type_badge_class(type) = BADGE_CLASSES.fetch(type, "bg-gray-100")
  def waste_type_options = WasteCollectionSeries::TYPES.map { |type| [ waste_type_label(type), type ] }
  def weekday_label(index) = t("waste.weekdays.#{WEEKDAY_KEYS.fetch(index, index.to_s)}", default: index.to_s)
  def weekday_options = (0..6).map { |index| [ weekday_label(index), index ] }
end

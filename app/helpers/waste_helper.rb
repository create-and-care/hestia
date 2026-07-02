module WasteHelper
  TYPES = {
    "ordures"     => [ "Ordures ménagères", "🗑", "bg-gray-200 text-gray-800" ],
    "recyclage"   => [ "Recyclage", "♻️", "bg-yellow-100 text-yellow-800" ],
    "verre"       => [ "Verre", "🍶", "bg-green-100 text-green-800" ],
    "compost"     => [ "Compost", "🌱", "bg-amber-100 text-amber-800" ],
    "encombrants" => [ "Encombrants", "🛋", "bg-blue-100 text-blue-800" ]
  }.freeze

  WEEKDAYS = %w[Dimanche Lundi Mardi Mercredi Jeudi Vendredi Samedi].freeze

  def waste_type_label(type) = TYPES.fetch(type, [ type, "🗑", "bg-gray-100" ]).first
  def waste_type_icon(type) = TYPES.fetch(type, [ type, "🗑", "bg-gray-100" ])[1]
  def waste_type_badge_class(type) = TYPES.fetch(type, [ type, "🗑", "bg-gray-100" ]).last
  def waste_type_options = WasteCollectionSeries::TYPES.map { |type| [ waste_type_label(type), type ] }
  def weekday_label(index) = WEEKDAYS.fetch(index, index.to_s)
  def weekday_options = (0..6).map { |index| [ weekday_label(index), index ] }
end

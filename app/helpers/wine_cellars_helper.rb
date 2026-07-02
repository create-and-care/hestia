module WineCellarsHelper
  WINE_TYPE_LABELS = {
    "rouge" => "Rouge", "blanc" => "Blanc", "rose" => "Rosé",
    "petillant" => "Pétillant", "autre" => "Autre"
  }.freeze

  def wine_type_label(type) = WINE_TYPE_LABELS.fetch(type, type.to_s.humanize)
  def wine_type_options = Bottle::WINE_TYPES.map { |type| [ wine_type_label(type), type ] }

  def cellar_options
    Current.household.wine_cellars.order(:name).map { |cellar| [ cellar.name, cellar.id ] }
  end
end

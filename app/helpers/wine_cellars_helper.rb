module WineCellarsHelper
  def wine_type_label(type) = t("wine_cellars.wine_types.#{type}", default: type.to_s.humanize)
  def wine_type_options = Bottle::WINE_TYPES.map { |type| [ wine_type_label(type), type ] }

  def cellar_options
    Current.household.wine_cellars.order(:name).map { |cellar| [ cellar.name, cellar.id ] }
  end
end

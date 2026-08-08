module DocumentsHelper
  def folder_color_dot_class(color) = Swatch.dot_classes(color)

  def folder_color_options
    [ [ t("documents.index.no_color_option"), "" ] ] + DocumentFolder::COLORS.map { |color| [ t("documents.colors.#{color}"), color ] }
  end
end

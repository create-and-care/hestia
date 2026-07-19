module DocumentsHelper
  FOLDER_COLOR_CLASSES = {
    "blue" => "bg-blue-500",
    "green" => "bg-green-500",
    "red" => "bg-red-500",
    "purple" => "bg-purple-500",
    "orange" => "bg-orange-500",
    "gray" => "bg-gray-500"
  }.freeze

  def folder_color_dot_class(color) = FOLDER_COLOR_CLASSES.fetch(color, nil)

  def folder_color_options
    [ [ t("documents.index.no_color_option"), "" ] ] + DocumentFolder::COLORS.map { |color| [ t("documents.colors.#{color}"), color ] }
  end
end

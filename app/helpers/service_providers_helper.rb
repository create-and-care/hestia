module ServiceProvidersHelper
  DOT_CLASSES = {
    "red" => "bg-red-500",
    "orange" => "bg-orange-500",
    "yellow" => "bg-yellow-500",
    "green" => "bg-green-500",
    "blue" => "bg-blue-500",
    "purple" => "bg-purple-500",
    "pink" => "bg-pink-500",
    "gray" => "bg-gray-400"
  }.freeze

  def service_provider_type_dot_class(color)
    DOT_CLASSES.fetch(color, nil)
  end

  def service_provider_type_predefined_options
    predefined = ServiceProviderType::PREDEFINED_NAMES.map { |key| t("service_provider_types.predefined.#{key}") }.map { |name| [ name, name ] }
    predefined + [ [ t("service_providers.index.other_type_option"), "other" ] ]
  end
end

module ServiceProvidersHelper
  def service_provider_type_dot_class(color) = Swatch.dot_classes(color)

  def service_provider_type_predefined_options
    predefined = ServiceProviderType::PREDEFINED_NAMES.map { |key| t("service_provider_types.predefined.#{key}") }.map { |name| [ name, name ] }
    predefined + [ [ t("service_providers.index.other_type_option"), "other" ] ]
  end
end

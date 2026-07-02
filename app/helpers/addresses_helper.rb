module AddressesHelper
  TYPE_LABELS = {
    "restaurant" => "Restaurant", "cafe" => "Café", "bar" => "Bar", "hotel" => "Hôtel",
    "boutique" => "Boutique", "parc" => "Parc", "musee" => "Musée", "cinema" => "Cinéma",
    "theatre" => "Théâtre", "bien_etre" => "Bien-être", "lieu_phare" => "Lieu phare",
    "tourisme" => "Tourisme", "prive" => "Adresse privée", "autre" => "Autre"
  }.freeze

  def address_type_label(type) = TYPE_LABELS.fetch(type, type.to_s.humanize)
  def address_type_options = Address::TYPES.map { |type| [ address_type_label(type), type ] }
end

module AddressesHelper
  def address_type_label(type) = t("addresses.types.#{type}", default: type.to_s.humanize)
  def address_type_options = Address::TYPES.map { |type| [ address_type_label(type), type ] }
  def address_rating_stars(rating) = Array.new(rating.to_i, "★").join
end

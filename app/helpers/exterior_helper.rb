module ExteriorHelper
  ACTION_TYPES = %w[nettoyage_filtre hivernage mise_en_route autre].freeze

  def treatment_label(type) = t("exterior.treatments.#{type}", default: type)
  def treatment_options = Pool::TREATMENT_TYPES.map { |type| [ treatment_label(type), type ] }
  def pool_action_label(type) = t("exterior.action_types.#{type}", default: type)
  def pool_action_options = ACTION_TYPES.map { |type| [ pool_action_label(type), type ] }
end

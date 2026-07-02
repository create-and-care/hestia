module ExteriorHelper
  TREATMENT_LABELS = {
    "chlore" => "Chlore", "sel" => "Sel", "brome" => "Brome",
    "oxygene_actif" => "Oxygène actif", "uv" => "UV"
  }.freeze

  ACTION_TYPES = %w[nettoyage_filtre hivernage mise_en_route autre].freeze
  ACTION_LABELS = {
    "nettoyage_filtre" => "Nettoyage filtre", "hivernage" => "Hivernage",
    "mise_en_route" => "Mise en route", "autre" => "Autre"
  }.freeze

  def treatment_label(type) = TREATMENT_LABELS.fetch(type, type)
  def treatment_options = Pool::TREATMENT_TYPES.map { |type| [ treatment_label(type), type ] }
  def pool_action_label(type) = ACTION_LABELS.fetch(type, type)
  def pool_action_options = ACTION_TYPES.map { |type| [ pool_action_label(type), type ] }
end

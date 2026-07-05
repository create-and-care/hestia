# Catalogue de fiches d'entretien de plantes (CDC §11.3), constitué progressivement
# (cf. seed dans db/seeds.rb). Une Plant sans référence associée reste fonctionnelle,
# simplement sans la valeur d'aide à l'entretien.
class PlantReference < ApplicationRecord
  has_many :plants, dependent: :nullify

  validates :common_name, presence: true, uniqueness: true

  scope :ordered, -> { order(:common_name) }
end

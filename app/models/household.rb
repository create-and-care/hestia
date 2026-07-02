class Household < ApplicationRecord
  # Lisible à l'oral et sans caractères ambigus (pas de 0/O/1/I).
  INVITE_CODE_ALPHABET = (("A".."Z").to_a - %w[I O]) + ("2".."9").to_a
  INVITE_CODE_LENGTH = 8

  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships

  # Modules (Phase 2)
  has_many :shopping_lists, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :fridge_items, dependent: :destroy
  has_many :prepared_dishes, dependent: :destroy
  has_many :recipes, dependent: :destroy
  has_many :task_categories, dependent: :destroy
  has_many :tasks, dependent: :destroy
  has_many :calendar_events, dependent: :destroy

  # Modules satellites (Phase 2.b)
  has_many :notes, dependent: :destroy
  has_many :contacts, dependent: :destroy
  has_many :contact_tags, dependent: :destroy
  has_many :addresses, dependent: :destroy
  has_many :service_provider_types, dependent: :destroy
  has_many :service_providers, dependent: :destroy
  has_many :loyalty_cards, dependent: :destroy
  has_many :pets, dependent: :destroy
  has_many :vehicles, dependent: :destroy
  has_many :wine_cellars, dependent: :destroy
  has_many :bottles, dependent: :destroy
  has_many :waste_collection_series, dependent: :destroy
  has_many :waste_collection_events, dependent: :destroy
  has_many :baby_profiles, dependent: :destroy
  has_many :conversations, dependent: :destroy

  # Modules à logique métier riche (Phase 2.c)
  has_many :meal_plan_entries, dependent: :destroy

  validates :name, presence: true
  validates :invite_code, presence: true, uniqueness: true

  before_validation :ensure_invite_code, on: :create

  def regenerate_invite_code!
    update!(invite_code: self.class.generate_invite_code)
  end

  def self.generate_invite_code
    loop do
      code = Array.new(INVITE_CODE_LENGTH) { INVITE_CODE_ALPHABET.sample }.join
      break code unless exists?(invite_code: code)
    end
  end

  private
    def ensure_invite_code
      self.invite_code ||= self.class.generate_invite_code
    end
end

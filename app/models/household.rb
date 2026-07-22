class Household < ApplicationRecord
  # Readable aloud and without ambiguous characters (no 0/O/1/I).
  INVITE_CODE_ALPHABET = (("A".."Z").to_a - %w[I O]) + ("2".."9").to_a
  INVITE_CODE_LENGTH = 8

  # Public holidays displayable in the Calendar, optionally enabled.
  HOLIDAY_COUNTRIES = %w[FR BE CH].freeze

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

  # Satellite modules (Phase 2.b)
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

  # Modules with rich business logic (Phase 2.c)
  has_many :meal_plan_entries, dependent: :destroy
  has_many :routines, dependent: :destroy
  has_many :plants, dependent: :destroy
  has_many :pools, dependent: :destroy
  has_many :budget_categories, dependent: :destroy
  has_many :savings_envelopes, dependent: :destroy
  has_many :shared_projects, dependent: :destroy
  has_many :document_folders, dependent: :destroy
  has_many :documents, dependent: :destroy

  # Modules with architectural deviation (Phase 2.d)
  has_many :gift_lists, dependent: :destroy
  has_many :trips, dependent: :destroy

  # Every module key that appears in the sidebar (SidebarHelper::SIDEBAR_GROUPS
  # is the single source of truth) can be turned off per household.
  MODULE_KEYS = SidebarHelper::SIDEBAR_GROUPS.flat_map { |group| group[:items].map { |_icon, key, _path| key.to_s } }.freeze

  validates :name, presence: true
  validates :invite_code, presence: true, uniqueness: true
  validates :holiday_country, inclusion: { in: HOLIDAY_COUNTRIES }, allow_blank: true
  validates :time_zone, inclusion: { in: ActiveSupport::TimeZone.all.map(&:name) }
  validate :disabled_modules_are_known_keys
  validate :required_meal_types_are_known_types

  before_validation :ensure_invite_code, on: :create
  before_validation :compact_required_meal_types

  def regenerate_invite_code!
    update!(invite_code: self.class.generate_invite_code)
  end

  def module_enabled?(key)
    disabled_modules.exclude?(key.to_s)
  end

  def admin?(user)
    memberships.exists?(user: user, role: "admin")
  end

  # True when `user` is an admin and the only one — used to block leaving,
  # demoting, or removing a household's last remaining admin.
  def only_admin?(user)
    admin?(user) && memberships.where(role: "admin").count == 1
  end

  # "Today"-sensitive calculations (Fridge expiry, Task due dates, birthdays)
  # must resolve against the household's own time zone rather than the
  # server's, since members can be anywhere. See ApplicationController#switch_time_zone
  # for the per-request equivalent; used directly by background jobs
  # (Reminders::DailyDigest), which run outside a request.
  def in_time_zone(&block)
    Time.use_zone(time_zone, &block)
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

    def disabled_modules_are_known_keys
      unknown = disabled_modules.to_a - MODULE_KEYS
      errors.add(:disabled_modules, "contains unknown module keys: #{unknown.join(', ')}") if unknown.any?
    end

    def required_meal_types_are_known_types
      unknown = required_meal_types.to_a - MealPlanEntry::MEAL_TYPES
      errors.add(:required_meal_types, "contains unknown meal types: #{unknown.join(', ')}") if unknown.any?
    end

    # The settings form submits a hidden "" fallback alongside the checkboxes
    # (so unchecking everything still sends an empty array instead of
    # omitting the param entirely) — strip it out before validating.
    def compact_required_meal_types
      self.required_meal_types = required_meal_types.to_a.reject(&:blank?)
    end
end

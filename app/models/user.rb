class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :households, through: :memberships
  has_many :conversation_participants, dependent: :destroy
  has_many :conversations, through: :conversation_participants
  has_many :circle_memberships, dependent: :destroy
  has_many :circles, through: :circle_memberships

  # Wellbeing module: data strictly private to the user (never the household).
  has_one :wellbeing_profile, dependent: :destroy
  has_many :weight_entries, dependent: :destroy
  has_many :workout_entries, dependent: :destroy

  # Reminders & notifications (Spec §9.2, §9.3, §9.4, §10.2).
  has_many :notifications, dependent: :destroy
  has_many :task_reminders, dependent: :destroy
  has_many :event_reminders, dependent: :destroy
  has_one :notification_preference, dependent: :destroy

  # External calendar synchronization (Spec §9.2, §16).
  has_many :external_calendar_connections, dependent: :destroy

  # Mobile API (Spec §15).
  has_many :api_tokens, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :name, presence: true
  validates :email_address, presence: true, uniqueness: true
end

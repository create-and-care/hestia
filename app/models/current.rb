class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :household
  delegate :user, to: :session, allow_nil: true
end

class ContactTagging < ApplicationRecord
  belongs_to :contact
  belongs_to :contact_tag

  validates :contact_id, uniqueness: { scope: :contact_tag_id }
end

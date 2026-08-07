require "test_helper"

class ContactTaggingTest < ActiveSupport::TestCase
  test "requires a contact and a contact tag" do
    tagging = ContactTagging.new
    assert_not tagging.valid?
  end

  test "prevents tagging the same contact with the same tag twice" do
    contact = contacts(:alpha_mom)
    tag = contact_tags(:alpha_family)
    ContactTagging.create!(contact: contact, contact_tag: tag)

    duplicate = ContactTagging.new(contact: contact, contact_tag: tag)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:contact_id], error_message(:taken)
  end

  test "allows the same contact to have different tags" do
    contact = contacts(:alpha_mom)
    ContactTagging.create!(contact: contact, contact_tag: contact_tags(:alpha_family))
    other_tag = households(:alpha).contact_tags.create!(name: "Amis")

    second = ContactTagging.new(contact: contact, contact_tag: other_tag)
    assert second.valid?
  end
end

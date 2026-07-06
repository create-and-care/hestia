require "test_helper"

class ContactTagTest < ActiveSupport::TestCase
  test "requires a name" do
    tag = households(:alpha).contact_tags.build
    assert_not tag.valid?
    tag.name = "Famille"
    assert tag.valid?
  end

  test "contacts are reachable through taggings" do
    tag = contact_tags(:alpha_family)
    contact = contacts(:alpha_mom)
    tag.contacts << contact
    assert_includes tag.reload.contacts, contact
  end

  test "destroying a tag destroys its taggings but not the contacts" do
    tag = contact_tags(:alpha_family)
    contact = contacts(:alpha_mom)
    tag.contacts << contact

    assert_difference -> { ContactTagging.count }, -1 do
      assert_no_difference -> { Contact.count } do
        tag.destroy
      end
    end
  end

  test "is scoped to its household" do
    assert_not_includes households(:alpha).contact_tags, contact_tags(:beta_tag)
  end
end

require "test_helper"

class ContactTagsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create requires authentication" do
    sign_out
    post contact_tags_path, params: { contact_tag: { name: "Amis", emoji: "🎉" } }
    assert_redirected_to new_session_path
  end

  test "create adds a tag to the household" do
    assert_difference -> { households(:alpha).contact_tags.count }, 1 do
      post contact_tags_path, params: { contact_tag: { name: "Amis", emoji: "🎉" } }
    end
    assert_redirected_to contacts_path
  end

  test "create with a blank name does not persist" do
    assert_no_difference -> { ContactTag.count } do
      post contact_tags_path, params: { contact_tag: { name: "" } }
    end
    assert_redirected_to contacts_path
  end

  test "destroy" do
    tag = contact_tags(:alpha_family)
    delete contact_tag_path(tag)
    assert_redirected_to contacts_path
    assert_not ContactTag.exists?(tag.id)
  end

  test "cannot destroy another household's tag" do
    delete contact_tag_path(contact_tags(:beta_tag))
    assert_response :not_found
  end
end

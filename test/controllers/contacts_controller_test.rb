require "test_helper"

class ContactsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "index requires authentication" do
    sign_out
    get contacts_path
    assert_redirected_to new_session_path
  end

  test "index shows the household's contacts only" do
    get contacts_path
    assert_response :success
    assert_includes @response.body, "Maman"
    assert_not_includes @response.body, "Ami Beta"
  end

  test "new" do
    get new_contact_path
    assert_response :success
  end

  test "create with a household tag" do
    assert_difference -> { households(:alpha).contacts.count }, 1 do
      post contacts_path, params: {
        contact: { name: "Papa", born_on: "1960-05-05", year_known: "1" },
        contact_tag_ids: [ contact_tags(:alpha_family).id ]
      }
    end
    assert_redirected_to contacts_path
    assert_includes Contact.find_by!(name: "Papa").contact_tags, contact_tags(:alpha_family)
  end

  test "ignores a tag from another household" do
    post contacts_path, params: { contact: { name: "Papa2" }, contact_tag_ids: [ contact_tags(:beta_tag).id ] }
    assert_empty Contact.find_by!(name: "Papa2").contact_tags
  end

  test "filter by tag" do
    contacts(:alpha_mom).contact_tags << contact_tags(:alpha_family)
    get contacts_path(tag_id: contact_tags(:alpha_family).id)
    assert_response :success
    assert_includes @response.body, "Maman"
  end

  test "destroy" do
    contact = contacts(:alpha_mom)
    delete contact_path(contact)
    assert_redirected_to contacts_path
    assert_not Contact.exists?(contact.id)
  end

  test "cannot touch another household's contact" do
    get edit_contact_path(contacts(:beta_friend))
    assert_response :not_found
  end
end

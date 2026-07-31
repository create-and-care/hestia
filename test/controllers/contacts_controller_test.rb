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

  test "the add-birthday button has a visible label" do
    get contacts_path
    assert_response :success
    assert_select "a[href=?]", new_contact_path, text: "New contact"
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

  test "delete and edit controls have accessible names and a delete confirmation" do
    contact = contacts(:alpha_mom)
    get contacts_path
    assert_select "a[href=?][aria-label=?]", edit_contact_path(contact), "Edit \"Maman\""
    assert_select "form[action=?][data-turbo-confirm]", contact_path(contact)
  end

  test "distinguishes this week from this month with different badge colors" do
    assert_equal :urgent, ContactsHelper::PROXIMITY_VARIANTS[:week]
    assert_equal :warning, ContactsHelper::PROXIMITY_VARIANTS[:month]
  end

  test "shows a link to the contact's visible gift lists" do
    list = households(:alpha).gift_lists.create!(name: "Cadeau pour Maman", perspective: "give", contact: contacts(:alpha_mom))
    get contacts_path
    assert_select "a[href=?]", gift_list_path(list), text: /Cadeau pour Maman/
  end

  test "does not link a restricted gift list the current user cannot see" do
    other_user = users(:two)
    list = households(:alpha).gift_lists.create!(name: "Surprise", perspective: "give",
      contact: contacts(:alpha_mom), created_by: other_user, restricted: true, visible_to_ids: [ other_user.id ])
    get contacts_path
    assert_not_includes @response.body, "Surprise"
  end

  test "calendar shows the monthly grid with birthdays placed on their day" do
    # Anchored to the 15th of the current month (year 1960) rather than the
    # alpha_mom fixture's "Date.current + 3.days" — that offset rolls into
    # next month, off this month's grid, whenever today is near month-end.
    households(:alpha).contacts.create!(name: "Mamie", born_on: Date.new(1960, Date.current.month, 15))

    get calendar_contacts_path
    assert_response :success
    assert_select "[role='grid']"
    assert_includes @response.body, "Mamie"
  end

  test "calendar navigates to another month" do
    get calendar_contacts_path(month: "2026-01")
    assert_response :success
    assert_includes @response.body, "January 2026"
  end
end

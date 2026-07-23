require "application_system_test_case"

class ServiceProvidersTest < ApplicationSystemTestCase
  def sign_in_to_alpha
    visit new_session_path
    fill_in "email_address", with: users(:one).email_address
    fill_in "password", with: "password"
    click_on "Sign in"
    assert_text households(:alpha).name
  end

  test "the providers board only shows the signed-in household's providers" do
    sign_in_to_alpha
    visit service_providers_path
    assert_text service_providers(:alpha_plombier).name
    assert_no_text service_providers(:beta_provider).name
  end

  test "adding a type from the predefined list creates it immediately" do
    sign_in_to_alpha
    visit service_providers_path

    select "Gardener", from: "service_provider_type_name"
    click_on "Add"

    assert_text "Gardener"
    assert ServiceProviderType.exists?(name: "Gardener")
  end

  test "choosing Other reveals a custom field to add a new type" do
    sign_in_to_alpha
    visit service_providers_path

    select "Other…", from: "service_provider_type_name"
    assert_selector "#service_provider_type_name_custom"
    fill_in "service_provider_type_name_custom", with: "Coach sportif"
    click_on "Add"

    assert_text "Coach sportif"
    assert ServiceProviderType.exists?(name: "Coach sportif")
  end

  test "deleting a type shows the design-system alert dialog and decategorizes its providers" do
    sign_in_to_alpha
    type = service_provider_types(:alpha_plumber)
    provider = service_providers(:alpha_plombier)
    visit service_providers_path

    page.execute_script("arguments[0].click()", find(:button, "×").native)
    assert_selector "dialog[role='alertdialog'][data-state='open']"
    within "dialog[data-state='open']" do
      submit_button_to "Delete"
    end

    assert_no_text type.name
    assert_nil provider.reload.service_provider_type
  end
end

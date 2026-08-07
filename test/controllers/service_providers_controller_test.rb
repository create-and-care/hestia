require "test_helper"

class ServiceProvidersControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "index requires authentication" do
    sign_out
    get service_providers_path
    assert_redirected_to new_session_path
  end

  test "index shows the household's providers only" do
    get service_providers_path
    assert_response :success
    assert_includes @response.body, "Plomberie Martin"
    assert_not_includes @response.body, "Prestataire Beta"
  end

  test "filter by type" do
    get service_providers_path(type_id: service_provider_types(:alpha_plumber).id)
    assert_response :success
    assert_includes @response.body, "Plomberie Martin"
  end

  test "search" do
    get service_providers_path(q: "Martin")
    assert_response :success
    assert_includes @response.body, "Plomberie Martin"
  end

  test "edit lists documents linked to the provider" do
    document = households(:alpha).documents.build(name: "Devis", documentable: service_providers(:alpha_plombier))
    document.file.attach(io: File.open(Rails.root.join("test/fixtures/files/sample.pdf")), filename: "sample.pdf", content_type: "application/pdf")
    document.save!

    get edit_service_provider_path(service_providers(:alpha_plombier))
    assert_response :success
    assert_includes @response.body, "Devis"
  end

  test "create with a household type" do
    assert_difference -> { households(:alpha).service_providers.count }, 1 do
      post service_providers_path, params: {
        service_provider: { name: "Élec Dupont", service_provider_type_id: service_provider_types(:alpha_plumber).id }
      }
    end
    assert_redirected_to service_providers_path
  end

  test "ignores a type from another household" do
    post service_providers_path, params: {
      service_provider: { name: "Intrus", service_provider_type_id: service_provider_types(:beta_type).id }
    }
    assert_nil ServiceProvider.find_by!(name: "Intrus").service_provider_type_id
  end

  test "destroy" do
    provider = service_providers(:alpha_plombier)
    delete service_provider_path(provider)
    assert_redirected_to service_providers_path
    assert_not ServiceProvider.exists?(provider.id)
  end

  test "cannot touch another household's provider" do
    get edit_service_provider_path(service_providers(:beta_provider))
    assert_response :not_found
  end

  test "create links an address from the household's address book" do
    post service_providers_path, params: {
      service_provider: { name: "Vitrier", linked_address_id: addresses(:alpha_resto).id }
    }
    assert_equal addresses(:alpha_resto), ServiceProvider.find_by!(name: "Vitrier").linked_address
  end

  test "the provider form offers the household's addresses" do
    get new_service_provider_path
    assert_select "select#service_provider_linked_address_id option", text: addresses(:alpha_resto).name
    assert_select "select#service_provider_linked_address_id option", text: addresses(:beta_place).name, count: 0
  end

  test "the active type filter is highlighted, others are not" do
    plumber = service_provider_types(:alpha_plumber)
    get service_providers_path(type_id: plumber.id)
    assert_select "span.bg-button-primary" do
      assert_select "a[href=?]", service_providers_path(type_id: plumber.id)
    end
  end

  test "provider delete button asks for confirmation and has an accessible name" do
    provider = service_providers(:alpha_plombier)
    get service_providers_path
    assert_select "form[action=?][data-turbo-confirm]", service_provider_path(provider)
  end

  test "type delete button uses the design-system alert dialog instead of a native confirm" do
    type = service_provider_types(:alpha_plumber)
    get service_providers_path
    assert_response :success
    assert_select "dialog[role='alertdialog']", count: 1
    assert_no_match(/data-turbo-confirm="#{Regexp.escape(I18n.t("service_providers.index.delete_type_confirm", name: type.name))}"/, @response.body)
  end

  test "the new-type form offers a predefined list plus a custom fallback field" do
    get service_providers_path
    assert_response :success
    assert_select "select#service_provider_type_name option", text: I18n.t("service_provider_types.predefined.plumber")
    assert_select "select#service_provider_type_name option", text: I18n.t("service_providers.index.other_type_option")
    assert_select "input#service_provider_type_name_custom"
  end

  test "search input is wired for debounced auto-submit" do
    get service_providers_path
    assert_select "form[data-controller='debounced-search']" do
      assert_select "input[data-action='input->debounced-search#submit']"
    end
  end

  test "provider form is wired for the mobile contact picker" do
    get new_service_provider_path
    assert_select "[data-controller='contact-picker']" do
      assert_select "[data-contact-picker-target='name']"
      assert_select "[data-contact-picker-target='phone']"
      assert_select "[data-contact-picker-target='email']"
    end
  end
end

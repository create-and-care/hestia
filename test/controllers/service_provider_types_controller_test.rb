require "test_helper"

class ServiceProviderTypesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create adds a type to the household" do
    assert_difference -> { households(:alpha).service_provider_types.count }, 1 do
      post service_provider_types_path, params: { service_provider_type: { name: "Électricien", icon: "⚡" } }
    end
    assert_redirected_to service_providers_path
  end

  test "destroy removes the type" do
    type = service_provider_types(:alpha_plumber)
    delete service_provider_type_path(type)
    assert_redirected_to service_providers_path
    assert_not ServiceProviderType.exists?(type.id)
  end

  test "cannot destroy another household's type" do
    assert_no_difference -> { ServiceProviderType.count } do
      delete service_provider_type_path(service_provider_types(:beta_type))
    end
    assert_response :not_found
  end
end

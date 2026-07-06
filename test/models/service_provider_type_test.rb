require "test_helper"

class ServiceProviderTypeTest < ActiveSupport::TestCase
  test "requires a name" do
    type = households(:alpha).service_provider_types.build
    assert_not type.valid?
    type.name = "Plombier"
    assert type.valid?
  end

  test "nullifies its service providers when destroyed" do
    type = service_provider_types(:alpha_plumber)
    provider = service_providers(:alpha_plombier)
    assert_equal type, provider.service_provider_type

    type.destroy

    assert_nil provider.reload.service_provider_type_id
  end

  test "is scoped to its household" do
    assert_not_includes households(:alpha).service_provider_types, service_provider_types(:beta_type)
  end
end

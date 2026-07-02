require "test_helper"

class ServiceProviderTest < ActiveSupport::TestCase
  test "requires a name" do
    provider = households(:alpha).service_providers.build
    assert_not provider.valid?
    provider.name = "X"
    assert provider.valid?
  end

  test "maps_url from the address" do
    assert_includes service_providers(:alpha_plombier).maps_url, "search?query="
    assert_nil ServiceProvider.new.maps_url
  end

  test "is scoped to its household" do
    assert_not_includes households(:alpha).service_providers, service_providers(:beta_provider)
  end
end

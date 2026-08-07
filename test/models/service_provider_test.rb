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

  test "maps_url prefers the linked address over the free-text address" do
    provider = service_providers(:alpha_plombier)
    provider.linked_address = addresses(:alpha_resto)
    assert_equal addresses(:alpha_resto).maps_url, provider.maps_url
  end

  test "rejects a linked address from another household" do
    provider = households(:alpha).service_providers.build(name: "X", linked_address: addresses(:beta_place))
    assert_not provider.valid?
    assert_includes provider.errors[:linked_address], error_message(:invalid)
  end
end

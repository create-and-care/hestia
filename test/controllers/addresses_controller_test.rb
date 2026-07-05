require "test_helper"

class AddressesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "index requires authentication" do
    sign_out
    get addresses_path
    assert_redirected_to new_session_path
  end

  test "index shows the household's addresses only" do
    get addresses_path
    assert_response :success
    assert_includes @response.body, "Chez Léon"
    assert_not_includes @response.body, "Bar Beta"
  end

  test "filter by type" do
    get addresses_path(address_type: "parc")
    assert_response :success
    assert_includes @response.body, "Parc de la Tête"
    assert_not_includes @response.body, "Chez Léon"
  end

  test "search" do
    get addresses_path(q: "Léon")
    assert_response :success
    assert_includes @response.body, "Chez Léon"
  end

  test "create" do
    assert_difference -> { households(:alpha).addresses.count }, 1 do
      post addresses_path, params: { address: { name: "Musée X", address_type: "musee" } }
    end
    assert_redirected_to addresses_path
  end

  test "destroy" do
    address = addresses(:alpha_resto)
    delete address_path(address)
    assert_redirected_to addresses_path
    assert_not Address.exists?(address.id)
  end

  test "cannot touch another household's address" do
    get edit_address_path(addresses(:beta_place))
    assert_response :not_found
  end

  test "online search geocodes a query via Nominatim" do
    stub_request(:get, %r{nominatim\.openstreetmap\.org/search})
      .to_return(status: 200, body: [ { "display_name" => "Tour Eiffel, Paris", "lat" => "48.8", "lon" => "2.29" } ].to_json)

    get search_addresses_path(q: "Tour Eiffel")

    assert_response :success
    assert_equal "Tour Eiffel", JSON.parse(@response.body).first["name"]
  end
end

require "test_helper"

module Geocoding
  class SearchAddressTest < ActiveSupport::TestCase
    test "returns matching places with coordinates" do
      stub_request(:get, %r{nominatim\.openstreetmap\.org/search})
        .to_return(
          status: 200,
          body: [
            { "display_name" => "Tour Eiffel, Paris, France", "lat" => "48.8584", "lon" => "2.2945" }
          ].to_json
        )

      results = Geocoding::SearchAddress.call(query: "Tour Eiffel")
      assert_equal 1, results.size
      assert_equal "Tour Eiffel", results.first[:name]
      assert_in_delta 48.8584, results.first[:latitude], 0.0001
    end

    test "returns an empty array when nothing matches" do
      stub_request(:get, %r{nominatim\.openstreetmap\.org/search}).to_return(status: 200, body: "[]")

      assert_equal [], Geocoding::SearchAddress.call(query: "xyzxyzxyz")
    end

    test "returns an empty array on network failure instead of raising" do
      stub_request(:get, %r{nominatim\.openstreetmap\.org}).to_timeout

      assert_equal [], Geocoding::SearchAddress.call(query: "Tour Eiffel")
    end

    test "returns an empty array for a blank query without any HTTP call" do
      assert_equal [], Geocoding::SearchAddress.call(query: "  ")
    end

    # Nominatim's usage policy asks for one request at a time and no repeated
    # identical queries; the address form fires on every submit, so the same
    # street gets looked up again and again as a household adds its contacts.
    test "an identical query is served from the cache" do
      stub = stub_request(:get, %r{nominatim\.openstreetmap\.org/search})
        .to_return(status: 200, body: [ { "display_name" => "Tour Eiffel, Paris", "lat" => "48.8", "lon" => "2.2" } ].to_json)

      with_cache do
        first = Geocoding::SearchAddress.call(query: "Tour Eiffel")
        second = Geocoding::SearchAddress.call(query: "  tour eiffel ") # same address, typed differently

        assert_equal first, second
        assert_requested stub, times: 1
      end
    end

    test "an empty result is not cached, so a timeout cannot pin an address to nothing" do
      stub = stub_request(:get, %r{nominatim\.openstreetmap\.org}).to_timeout

      with_cache do
        2.times { assert_equal [], Geocoding::SearchAddress.call(query: "Tour Eiffel") }

        assert_requested stub, times: 2
      end
    end
  end
end

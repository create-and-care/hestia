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
  end
end

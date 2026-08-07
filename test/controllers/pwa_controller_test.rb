require "test_helper"

# The manifest and the service worker existed on disk from the day the app was
# generated, but their routes and the layout's <link rel="manifest"> were
# commented out, so the app was not installable and the worker was never
# fetched (DS-09). These tests are what stops that from silently happening
# again — every one of them would have failed before.
class PwaControllerTest < ActionDispatch::IntegrationTest
  test "the manifest is served signed out, as a manifest" do
    get pwa_manifest_path

    assert_response :success
    assert_equal "application/manifest+json", @response.media_type
  end

  test "the manifest carries everything a browser needs to offer installation" do
    get pwa_manifest_path
    manifest = JSON.parse(@response.body)

    assert_equal "Hestia", manifest["name"]
    assert_equal "/", manifest["start_url"]
    assert_equal "standalone", manifest["display"]
    assert manifest["description"].present?
    # "red" was the scaffold's placeholder for both of these.
    assert_match(/\A#[0-9A-Fa-f]{6}\z/, manifest["theme_color"])
    assert_match(/\A#[0-9A-Fa-f]{6}\z/, manifest["background_color"])
  end

  # A manifest may declare any size it likes; the file behind it is what the
  # browser measures. /icon.png was 480×360 and declared as 512×512, which on
  # its own is enough to be refused.
  test "every declared PNG icon exists and is square at the size it claims" do
    get pwa_manifest_path
    icons = JSON.parse(@response.body)["icons"].select { |icon| icon["type"] == "image/png" }

    assert_operator icons.size, :>=, 2
    icons.each do |icon|
      path = Rails.public_path.join(icon["src"].delete_prefix("/"))
      assert path.exist?, "#{icon['src']} is declared in the manifest but not on disk"

      side = icon["sizes"][/\A(\d+)x/, 1].to_i
      assert_equal [ side, side ], png_dimensions(path), "#{icon['src']} is not #{icon['sizes']}"
    end
  end

  test "a maskable icon is offered, so a round launcher does not clip the roof" do
    get pwa_manifest_path
    purposes = JSON.parse(@response.body)["icons"].map { |icon| icon["purpose"] }

    assert_includes purposes, "maskable"
  end

  test "the service worker is served with the header that lets it claim the whole origin" do
    get pwa_service_worker_path

    assert_response :success
    assert_equal "text/javascript", @response.media_type
    assert_equal "/", @response.headers["Service-Worker-Allowed"],
      "without this the worker may only control /service-worker/*"
  end

  test "the service worker precaches the offline page it falls back to" do
    get pwa_service_worker_path
    offline_url = @response.body[/OFFLINE_URL = "([^"]+)"/, 1]

    assert offline_url.present?, "the worker declares no offline page"
    assert Rails.public_path.join(offline_url.delete_prefix("/")).exist?,
      "#{offline_url} is precached by the worker but does not exist"
  end

  test "the layout links the manifest" do
    sign_in_as(users(:one))

    get root_path

    assert_select "link[rel=manifest][href=?]", pwa_manifest_path
  end

  private
    # The IHDR chunk of a PNG: width and then height, as big-endian 32-bit
    # integers, always at bytes 16..23.
    def png_dimensions(path)
      path.binread(24).unpack("x16NN")
    end
end

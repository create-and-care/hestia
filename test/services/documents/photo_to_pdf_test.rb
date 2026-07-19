require "test_helper"

class Documents::PhotoToPdfTest < ActiveSupport::TestCase
  test "wraps an image into a single-page PDF" do
    uploaded = Rack::Test::UploadedFile.new(Rails.root.join("test/fixtures/files/sample.png"), "image/png")

    pdf_io = Documents::PhotoToPdf.call(uploaded)

    assert_equal "%PDF", pdf_io.read(4)
  end
end

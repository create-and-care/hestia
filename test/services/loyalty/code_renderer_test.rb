require "test_helper"

module Loyalty
  class CodeRendererTest < ActiveSupport::TestCase
    test "renders a scannable QR code as inline SVG" do
      card = LoyaltyCard.new(number: "9876543210123", code_format: "qrcode")
      svg = CodeRenderer.call(card)
      assert_includes svg, "<svg"
      assert_includes svg, "viewBox"
    end

    test "renders a scannable barcode as inline SVG" do
      card = LoyaltyCard.new(number: "ABC123456", code_format: "barcode")
      svg = CodeRenderer.call(card)
      assert_includes svg, "<svg"
    end

    test "the svg scales responsively instead of using barby's fixed pixel size" do
      card = LoyaltyCard.new(number: "123", code_format: "qrcode")
      svg = CodeRenderer.call(card)
      assert_includes svg, 'width="100%"'
      assert_includes svg, 'height="auto"'
    end

    test "returns nil instead of raising for a number the barcode format can't encode" do
      card = LoyaltyCard.new(number: "café €", code_format: "barcode")
      assert_nil CodeRenderer.call(card)
    end
  end
end

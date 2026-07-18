require "barby/barcode/qr_code"
require "barby/barcode/code_128"
require "barby/outputter/svg_outputter"

module Loyalty
  # Renders a real, scannable barcode/QR code as inline SVG for a loyalty card's
  # code_format — no JS dependency, no native image library (barby's SVG outputter and
  # rqrcode are both pure Ruby), so it renders identically in every deployment.
  class CodeRenderer
    def self.call(card)
      barcode = card.code_format == "qrcode" ? Barby::QrCode.new(card.number) : Barby::Code128B.new(card.number)
      svg = barcode.to_svg(margin: 0)
      # Strips the fixed pixel width/height barby computes from the module count so the SVG
      # scales responsively to its container instead — the viewBox (kept) preserves the
      # barcode's own aspect ratio.
      svg.sub(/\A<\?xml[^>]*\?>\s*/, "")
        .sub(/width="[^"]*"/, 'width="100%"')
        .sub(/height="[^"]*"/, 'height="auto"')
        .html_safe
    rescue StandardError
      nil
    end
  end
end

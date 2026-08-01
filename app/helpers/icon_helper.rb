module IconHelper
  # Vendored from lucide-static (https://lucide.dev, ISC license) into
  # app/assets/icons/lucide — not read from node_modules, which doesn't
  # survive into the production image (see Dockerfile).
  LUCIDE_ICONS_DIR = Rails.root.join("app/assets/icons/lucide")

  # Inlines a Lucide icon as SVG. Icons ship with stroke="currentColor", so
  # `css_class` controls both size (Tailwind size-*) and color like any other
  # text, and they inherit the surrounding element's color by default.
  def lucide_icon(name, css_class: "size-4", **html_options)
    svg = LUCIDE_ICONS_DIR.join("#{name}.svg").read
    attrs = { class: css_class, "aria-hidden": true }.merge(html_options)
    attrs_html = attrs.map { |key, value| %(#{key}="#{ERB::Util.html_escape(value)}") }.join(" ")
    raw(svg.sub(/class="[^"]*"/, attrs_html))
  end

  # Same icon set, painted via CSS mask instead of inline SVG. Use this
  # instead of `lucide_icon` wherever the glyph must inherit a color that
  # isn't the surrounding text color — e.g. ModuleMedallion, where the glyph
  # is `text-module-*` but the element itself has no text content to inherit
  # `currentColor` from via stroke. `background-color: currentColor` clipped
  # to the icon shape achieves the same "colored by the parent" effect.
  def lucide_icon_mask(name, css_class: "size-4", **html_options)
    url = asset_path("lucide/#{name}.svg")
    mask = "url('#{url}') center / contain no-repeat"
    style = "mask: #{mask}; -webkit-mask: #{mask};"
    classes = [ "inline-block bg-current", css_class ].join(" ")
    attrs = { class: classes, style: style, "aria-hidden": true }.merge(html_options)
    tag.span(**attrs)
  end
end

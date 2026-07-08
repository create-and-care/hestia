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
end

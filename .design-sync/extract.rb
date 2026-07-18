# design-sync: dumps DesignSystemRegistry metadata and renders every docs-site
# preview partial to static HTML. Run: bin/rails runner .design-sync/extract.rb
# Output: .design-sync/out/registry.json + .design-sync/out/previews/<slug>.html
require "json"

# Keep dev-mode template-path comments out of the markup patterns.
ActionView::Base.annotate_rendered_view_with_filenames = false

out = Rails.root.join(".design-sync/out")
FileUtils.mkdir_p(out.join("previews"))

entries = DesignSystemRegistry.all.map do |e|
  {
    slug: e.slug,
    name: e.name,
    category: e.category,
    description: e.description,
    usage: e.usage,
    related: e.related,
    component_class: e.component_class&.name,
    props: e.props,
    enums: e.enums,
    slots: e.component_class ? e.slots : {}
  }
end
File.write(out.join("registry.json"), JSON.pretty_generate(entries))

failures = {}
DesignSystemRegistry.all.each do |entry|
  html = ApplicationController.render(partial: "design_system/previews/#{entry.slug}")
  File.write(out.join("previews", "#{entry.slug}.html"), html)
rescue => e
  failures[entry.slug] = "#{e.class}: #{e.message.lines.first&.strip}"
end

abort "preview render failures: #{failures.inspect}" if failures.any?
puts "extracted #{entries.size} entries, #{entries.size} previews rendered"

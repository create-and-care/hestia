module DesignSystemHelper
  # Reads a preview partial's own ERB source so the "Code" tab shown next to
  # a live demo can never drift from what's actually rendered — no snippet is
  # ever hand-duplicated. `slug` matches app/views/design_system/previews/_<slug>.html.erb.
  def design_system_source(slug)
    Rails.root.join("app/views/design_system/previews/_#{slug}.html.erb").read.strip
  end
end

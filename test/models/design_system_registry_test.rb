require "test_helper"

class DesignSystemRegistryTest < ActiveSupport::TestCase
  # The catalog is a hand-maintained list, so the only thing keeping it honest
  # is a test that walks the directory. It drifted to 73 entries for 75
  # components once already (Button To and View Toggle shipped with neither a
  # doc page nor a preview); this is what makes that a red build rather than a
  # discovery months later.
  def component_classes
    Dir[Rails.root.join("app/components/ui/*.rb")].map do |path|
      "Ui::#{File.basename(path, ".rb").camelize}".constantize
    end
  end

  test "every Ui component has a registry entry" do
    missing = component_classes - DesignSystemRegistry.all.map(&:component_class)

    assert_empty missing, "no /design-system entry for: #{missing.join(", ")}"
  end

  test "no registry entry points at a component that no longer exists" do
    stale = DesignSystemRegistry.all.map(&:component_class).compact - component_classes

    assert_empty stale, "registry entry for a missing component: #{stale.join(", ")}"
  end

  test "every entry has a preview partial, which is also its Code tab source" do
    DesignSystemRegistry.all.each do |entry|
      path = Rails.root.join("app/views/design_system/previews/_#{entry.slug}.html.erb")

      assert path.exist?, "#{entry.slug} has no preview partial at #{path}"
      assert path.read.strip.present?, "#{entry.slug}'s preview partial is empty"
    end
  end

  test "slugs are unique and related: only points at slugs that exist" do
    slugs = DesignSystemRegistry.all.map(&:slug)

    assert_equal slugs.size, slugs.uniq.size, "duplicate slugs: #{slugs.tally.select { |_, n| n > 1 }.keys.join(", ")}"

    DesignSystemRegistry.all.each do |entry|
      Array(entry.related).each do |slug|
        assert_includes slugs, slug, "#{entry.slug} links to an unknown component: #{slug}"
      end
    end
  end
end

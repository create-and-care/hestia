require "test_helper"

# Guards the named stacking scale (z-sticky / z-floating / z-overlay / z-toast,
# defined in application.tailwind.css). Before it, the order dialog → drawer →
# toast → tooltip was written down nowhere: twelve components each picked their
# own number, and the only way to learn that a toast has to clear an open
# dialog was to raise one and watch.
#
# A raw z-40 is not wrong on its own — it is wrong because it makes the next
# person guess. This test is what turns the scale from a convention into a rule.
class StackingOrderTest < ActiveSupport::TestCase
  RAW_Z_INDEX = /\bz-(\[\s*-?\d+\s*\]|\d+)\b/
  SCALE = %w[z-sticky z-floating z-overlay z-toast].freeze

  test "no raw z-index class in a view or a component" do
    offenders = source_files.flat_map do |path|
      File.readlines(path).filter_map.with_index(1) do |line, number|
        "#{relative_path(path)}:#{number} — #{line.strip}" if line.match?(RAW_Z_INDEX)
      end
    end

    assert_empty offenders, <<~MESSAGE
      Raw z-index classes found. Use the named scale instead
      (#{SCALE.join(", ")} — see the "Stacking order" block in
      app/assets/stylesheets/application.tailwind.css), or add a level to it if
      none of them says what you mean:

        #{offenders.join("\n  ")}
    MESSAGE
  end

  test "every level of the scale is defined in the stylesheet" do
    stylesheet = Rails.root.join("app/assets/stylesheets/application.tailwind.css").read

    SCALE.each do |level|
      assert_match(/@utility #{level} \{ z-index: \d+; \}/, stylesheet, "#{level} is used but never defined")
    end
  end

  # A native <dialog> opened with showModal() is promoted to the browser's top
  # layer, above every z-index on the page. Giving one a z-index puts it back
  # into ordinary stacking, underneath the toasts that are supposed to reach
  # the user through it.
  test "the dialog-family components carry no z-index of their own" do
    %w[dialog_component alert_dialog_component drawer_component].each do |component|
      path = Rails.root.join("app/components/ui/#{component}.html.erb")
      next unless path.exist?

      assert_no_match(/\bz-[\w\[\]-]+/, path.read, "#{component} must stay in the top layer, with no z-index")
    end
  end

  private

    def source_files
      Dir.glob(Rails.root.join("app/{views,components}/**/*.{erb,rb}"))
    end

    def relative_path(path)
      path.to_s.sub("#{Rails.root}/", "")
    end
end

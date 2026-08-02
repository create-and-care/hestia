require "test_helper"

class Ui::AlertComponentTest < ViewComponent::TestCase
  test "renders default variant with content" do
    render_inline(Ui::AlertComponent.new) { "Something went wrong" }

    assert_selector "div[role='alert']"
    assert_text "Something went wrong"
  end

  test "renders title slot" do
    render_inline(Ui::AlertComponent.new) do |c|
      c.with_title { "Heads up" }
      "Body copy"
    end

    assert_selector "div[role='alert'] p.font-medium", text: "Heads up"
    assert_text "Body copy"
  end

  test "renders icon slot" do
    render_inline(Ui::AlertComponent.new) do |c|
      c.with_icon { "ICON" }
      "Body copy"
    end

    assert_selector "div[role='alert'] > div.shrink-0", text: "ICON"
  end

  test "omits title and icon wrappers when slots are absent" do
    render_inline(Ui::AlertComponent.new) { "Body copy" }

    refute_selector "p.font-medium"
    refute_selector "div.shrink-0"
  end

  test "merges a custom class_name" do
    render_inline(Ui::AlertComponent.new(class_name: "mb-4")) { "Body copy" }

    assert_selector "div[role='alert'].mb-4"
  end

  test "renders every variant with its distinguishing class" do
    fragments = {
      default: "text-primary",
      success: "text-success",
      warning: "text-warning",
      destructive: "border-destructive"
    }

    Ui::AlertComponent::VARIANTS.each_key do |variant|
      render_inline(Ui::AlertComponent.new(variant: variant)) { "Alert body" }

      assert_selector "div[role='alert'].#{fragments.fetch(variant)}"
    end
  end

  test "carries the on-tone marker so a nested <a> inherits the alert's own color" do
    render_inline(Ui::AlertComponent.new) { "Body copy" }

    assert_selector "div[role='alert'].on-tone"
  end
end

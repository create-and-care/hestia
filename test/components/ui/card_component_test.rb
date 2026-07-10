require "test_helper"

class Ui::CardComponentTest < ViewComponent::TestCase
  test "renders content without header or footer" do
    render_inline(Ui::CardComponent.new) { "Plain body" }

    assert_selector "div.rounded-lg.border"
    refute_selector "h3"
    assert_selector "div.py-6", text: "Plain body"
  end

  test "renders title and description in a header block" do
    render_inline(Ui::CardComponent.new) do |c|
      c.with_title { "Card title" }
      c.with_description { "Card description" }
      "Body"
    end

    assert_selector "h3.font-semibold", text: "Card title"
    assert_selector "p.text-secondary", text: "Card description"
    assert_selector "div.pb-6", text: "Body"
  end

  test "renders footer slot" do
    render_inline(Ui::CardComponent.new) do |c|
      c.with_footer { "Footer content" }
      "Body"
    end

    assert_selector "div.px-6.pb-6", text: "Footer content"
  end

  test "merges a custom class name onto the root element" do
    render_inline(Ui::CardComponent.new(class_name: "my-card")) { "Body" }

    assert_selector "div.rounded-lg.my-card"
  end
end

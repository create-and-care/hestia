require "test_helper"

class Ui::InputGroupComponentTest < ViewComponent::TestCase
  test "renders content without leading or trailing slots" do
    render_inline(Ui::InputGroupComponent.new) { "<input type='text'>".html_safe }

    assert_selector "div.rounded-md.border"
    assert_selector "input"
    refute_selector "span"
  end

  test "renders leading and trailing slots around the content" do
    render_inline(Ui::InputGroupComponent.new) do |c|
      c.with_leading { "$" }
      c.with_trailing { ".00" }
      "<input type='text'>".html_safe
    end

    assert_selector "span.shrink-0", text: "$"
    assert_selector "span.shrink-0", text: ".00"
    assert_selector "input"
  end
end

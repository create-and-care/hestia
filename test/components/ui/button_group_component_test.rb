require "test_helper"

class Ui::ButtonGroupComponentTest < ViewComponent::TestCase
  test "renders default horizontal orientation" do
    render_inline(Ui::ButtonGroupComponent.new) { "<button>One</button><button>Two</button>".html_safe }

    assert_selector "div[role='group']", class: /rounded-l-md/
    assert_selector "div[role='group']", text: "OneTwo"
  end

  test "renders vertical orientation" do
    render_inline(Ui::ButtonGroupComponent.new(orientation: :vertical)) { "<button>One</button>".html_safe }

    assert_selector "div[role='group']", class: /flex-col/
    assert_selector "div[role='group']", class: /rounded-t-md/
  end
end

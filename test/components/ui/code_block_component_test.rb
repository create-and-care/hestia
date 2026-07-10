require "test_helper"

class Ui::CodeBlockComponentTest < ViewComponent::TestCase
  test "renders the preview content in the visible preview panel" do
    render_inline(Ui::CodeBlockComponent.new(code: "<%= render Ui::ButtonComponent.new %>")) { "Live preview content" }

    assert_selector "div[data-tabs-target='panel'][data-value='preview']:not([hidden])", text: "Live preview content"
  end

  test "renders the raw code string in a hidden code panel" do
    render_inline(Ui::CodeBlockComponent.new(code: "<button>Hi</button>")) { "Preview" }

    assert_selector "div[data-tabs-target='panel'][data-value='code'][hidden]", visible: false do
      assert_selector "pre code", text: "<button>Hi</button>", visible: false
    end
  end

  test "renders the preview/code tablist reusing the tabs controller's data contract" do
    render_inline(Ui::CodeBlockComponent.new(code: "puts 1")) { "Preview" }

    assert_selector "div[data-controller='tabs'][data-tabs-active-value='preview']"
    assert_selector "[role='tablist']"
    assert_selector "button[role='tab'][data-tabs-target='tab'][data-value='preview'][aria-selected='true']", text: "Aperçu"
    assert_selector "button[role='tab'][data-tabs-target='tab'][data-value='code'][aria-selected='false']", text: "Code"
  end

  test "renders a copy button wired to the clipboard controller with the same code" do
    render_inline(Ui::CodeBlockComponent.new(code: "puts 'hello'")) { "Preview" }

    assert_selector "div[data-controller='clipboard'][data-clipboard-text-value=\"puts 'hello'\"]"
    assert_selector "button[data-action='click->clipboard#copy'][aria-label='Copier le code']"
  end
end

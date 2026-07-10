require "test_helper"

class Ui::ContextMenuComponentTest < ViewComponent::TestCase
  test "renders the trigger area and a hidden menu panel wired to the controller" do
    render_inline(
      Ui::ContextMenuComponent.new(items: [ [ "Copy", "copy" ], :separator, [ "Delete", "delete" ] ])
    ) { "Right-click me" }

    assert_selector "[data-controller='context-menu'][data-action='contextmenu->context-menu#open']"
    assert_text "Right-click me"

    assert_selector "[data-context-menu-target='panel'][role='menu'][hidden][data-state='closed']", visible: false
    assert_selector(
      "[data-context-menu-target='panel'] button[role='menuitem'][data-action='click->context-menu#select'][data-value='copy']",
      text: "Copy", visible: false
    )
    assert_selector(
      "[data-context-menu-target='panel'] button[role='menuitem'][data-value='delete']",
      text: "Delete", visible: false
    )
    assert_selector "[data-context-menu-target='panel'] div.my-1.h-px.bg-tertiary", count: 1, visible: false
  end

  test "menu items are focusable via roving tabindex for keyboard navigation" do
    render_inline(
      Ui::ContextMenuComponent.new(items: [ [ "Copy", "copy" ], :separator, [ "Delete", "delete" ] ])
    ) { "Right-click me" }

    assert_selector "[data-context-menu-target='item'][role='menuitem'][tabindex='-1']", count: 2, visible: false
  end

  test "renders an empty panel when no items are given" do
    render_inline(Ui::ContextMenuComponent.new) { "Area" }

    assert_selector "[data-context-menu-target='panel']", visible: false
    refute_selector "[data-context-menu-target='panel'] button", visible: false
  end
end

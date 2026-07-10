require "test_helper"

class Ui::DropdownMenuComponentTest < ViewComponent::TestCase
  test "renders trigger and menu items wired to the Stimulus controller" do
    render_inline(
      Ui::DropdownMenuComponent.new(items: [ [ "Profile", "profile" ], :separator, [ "Log out", "logout" ] ])
    ) { |c| c.with_trigger { "Account" } }

    assert_selector "[data-controller='dropdown-menu']"
    assert_selector "[data-dropdown-menu-target='trigger'][data-action='click->dropdown-menu#toggle']", text: "Account"
    assert_selector "[data-dropdown-menu-target='trigger'][aria-haspopup='menu'][aria-expanded='false']", text: "Account"

    assert_selector "[data-dropdown-menu-target='panel'][role='menu'][hidden][data-state='closed']", visible: false

    trigger = page.find("[data-dropdown-menu-target='trigger']", visible: false)
    panel = page.find("[data-dropdown-menu-target='panel']", visible: false)
    assert_equal panel["id"], trigger["aria-controls"]
    assert panel["id"].present?
    assert_selector(
      "[data-dropdown-menu-target='item'][role='menuitem'][tabindex='-1']" \
      "[data-action='click->dropdown-menu#select'][data-value='profile']",
      text: "Profile", visible: false
    )
    assert_selector "[data-dropdown-menu-target='item'][data-value='logout']", text: "Log out", visible: false
    assert_selector "div.my-1.h-px.bg-tertiary", count: 1, visible: false
  end

  test "renders an empty panel when no items are given" do
    render_inline(Ui::DropdownMenuComponent.new) { |c| c.with_trigger { "Menu" } }

    assert_selector "[data-dropdown-menu-target='panel']", visible: false
    refute_selector "[data-dropdown-menu-target='item']", visible: false
  end
end

require "test_helper"

class Ui::MenubarComponentTest < ViewComponent::TestCase
  test "renders one dropdown-menu instance per top-level menu" do
    menus = [
      [ "File", [ [ "New", "new" ], [ "Open", "open" ] ] ],
      [ "Edit", [ [ "Undo", "undo" ] ] ]
    ]

    render_inline(Ui::MenubarComponent.new(menus: menus))

    assert_selector "[data-controller='dropdown-menu']", count: 2
    assert_selector "[data-dropdown-menu-target='trigger'] button", text: "File"
    assert_selector "[data-dropdown-menu-target='trigger'] button", text: "Edit"
    assert_selector "[data-dropdown-menu-target='item'][data-value='new']", text: "New", visible: false
    assert_selector "[data-dropdown-menu-target='item'][data-value='undo']", text: "Undo", visible: false
  end

  test "renders no dropdown-menu instances when there are no menus" do
    render_inline(Ui::MenubarComponent.new)

    refute_selector "[data-controller='dropdown-menu']"
  end

  test "wrapper has menubar role and top-level triggers have menuitem role" do
    menus = [ [ "File", [ [ "New", "new" ] ] ], [ "Edit", [ [ "Undo", "undo" ] ] ] ]

    render_inline(Ui::MenubarComponent.new(menus: menus))

    assert_selector "div[role='menubar']"
    assert_selector "[data-dropdown-menu-target='trigger'] button[role='menuitem']", count: 2
  end
end

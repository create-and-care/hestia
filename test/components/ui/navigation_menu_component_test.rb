require "test_helper"

class Ui::NavigationMenuComponentTest < ViewComponent::TestCase
  test "renders a nav with a trigger button per menu" do
    render_inline(Ui::NavigationMenuComponent.new) do |c|
      c.with_menu(label: "Product", key: "product") { "Product menu content" }
      c.with_menu(label: "Company", key: "company") { "Company menu content" }
    end

    assert_selector "nav[data-controller='navigation-menu']"
    assert_selector "button[data-navigation-menu-target='trigger'][data-key='product']", text: "Product"
    assert_selector "button[data-navigation-menu-target='trigger'][data-key='company']", text: "Company"
  end

  test "renders a panel per menu with the menu content, hidden by default" do
    render_inline(Ui::NavigationMenuComponent.new) do |c|
      c.with_menu(label: "Product", key: "product") { "Product menu content" }
    end

    assert_selector "div[data-navigation-menu-target='panel'][data-for='product'][hidden][data-state='closed']",
      text: "Product menu content", visible: :all
  end

  test "trigger wires up the toggle action" do
    render_inline(Ui::NavigationMenuComponent.new) do |c|
      c.with_menu(label: "Product", key: "product") { "Content" }
    end

    assert_selector "button[data-action*='click->navigation-menu#toggle']"
  end

  test "renders no triggers or panels when there are no menus" do
    render_inline(Ui::NavigationMenuComponent.new)

    refute_selector "button[data-navigation-menu-target='trigger']"
    refute_selector "div[data-navigation-menu-target='panel']"
  end

  test "trigger exposes menu popup semantics wired to its panel" do
    render_inline(Ui::NavigationMenuComponent.new) do |c|
      c.with_menu(label: "Product", key: "product") { "Product menu content" }
    end

    trigger = page.find("button[data-navigation-menu-target='trigger'][data-key='product']")
    panel = page.find("div[data-navigation-menu-target='panel'][data-for='product']", visible: :all)

    assert_equal "menu", trigger["aria-haspopup"]
    assert_equal "false", trigger["aria-expanded"]
    assert_equal panel[:id], trigger["aria-controls"]
    assert_equal "menu", panel["role"]
    assert_equal trigger[:id], panel["aria-labelledby"]
  end
end

require "test_helper"

class Ui::TabsComponentTest < ViewComponent::TestCase
  test "defaults to the first tab when no default is given" do
    render_inline(Ui::TabsComponent.new) do |c|
      c.with_tab(label: "Account", value: "account") { "Account panel" }
      c.with_tab(label: "Password", value: "password") { "Password panel" }
    end

    assert_selector "div[data-controller='tabs'][data-tabs-active-value='account']"
    assert_selector "div[role='tablist']"
    assert_selector "button[role='tab'][data-value='account'][aria-selected='true']", text: "Account"
    assert_selector "button[role='tab'][data-value='password'][aria-selected='false']", text: "Password"
  end

  test "honors an explicit default value" do
    render_inline(Ui::TabsComponent.new(default: "password")) do |c|
      c.with_tab(label: "Account", value: "account") { "Account panel" }
      c.with_tab(label: "Password", value: "password") { "Password panel" }
    end

    assert_selector "div[data-tabs-active-value='password']"
    assert_selector "button[role='tab'][data-value='password'][aria-selected='true']"
    assert_selector "button[role='tab'][data-value='account'][aria-selected='false']"
  end

  test "only the active panel is visible" do
    render_inline(Ui::TabsComponent.new(default: "password")) do |c|
      c.with_tab(label: "Account", value: "account") { "Account panel content" }
      c.with_tab(label: "Password", value: "password") { "Password panel content" }
    end

    assert_selector "div[data-tabs-target='panel'][data-value='password']", text: "Password panel content"
    assert_selector "div[data-tabs-target='panel'][data-value='account'][hidden]", text: "Account panel content", visible: :all
  end

  test "tab buttons wire up the select action" do
    render_inline(Ui::TabsComponent.new) do |c|
      c.with_tab(label: "Account", value: "account") { "Account panel" }
    end

    assert_selector "button[data-action*='click->tabs#select']"
  end

  test "tabs and panels are linked via aria-controls/aria-labelledby and have roving tabindex" do
    render_inline(Ui::TabsComponent.new) do |c|
      c.with_tab(label: "Account", value: "account") { "Account panel" }
      c.with_tab(label: "Password", value: "password") { "Password panel" }
    end

    account_tab = page.find("button[role='tab'][data-value='account']")
    password_tab = page.find("button[role='tab'][data-value='password']")
    account_panel = page.find("div[data-tabs-target='panel'][data-value='account']", visible: :all)

    assert_equal account_panel[:id], account_tab["aria-controls"]
    assert_equal account_tab[:id], account_panel["aria-labelledby"]
    assert_equal "0", account_tab["tabindex"]
    assert_equal "-1", password_tab["tabindex"]
  end

  test "panels have role=tabpanel" do
    render_inline(Ui::TabsComponent.new) do |c|
      c.with_tab(label: "Account", value: "account") { "Account panel" }
    end

    assert_selector "div[role='tabpanel'][data-tabs-target='panel']", visible: :all
  end
end

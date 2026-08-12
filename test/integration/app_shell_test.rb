require "test_helper"

# The authenticated shell (shared/_app_sidebar) — not any one view. Covers the
# responsive split: a persistent aside >= md, and a Ui::DrawerComponent-backed
# nav below md triggered from a dedicated mobile top bar (see
# shared/_app_sidebar.html.erb and the "Défaut 1" writeup this implements).
class AppShellTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "the desktop aside is hidden below md and unchanged at/above md" do
    get root_path

    assert_select "aside[data-sidebar-target='panel'].max-md\\:hidden"
  end

  test "the mobile top bar is hidden at/above md and holds a hamburger trigger for the drawer" do
    get root_path

    assert_select "div.md\\:hidden [data-action='click->dialog#open'] button[aria-label='#{I18n.t("sidebar.open_nav")}']"
  end

  test "the mobile drawer closes on Turbo navigation and renders from the same nav partial" do
    get root_path

    assert_select "dialog[data-action='click->dialog#closeOnBackdrop cancel->dialog#onCancel']" do
      assert_select "[data-action='turbo:before-visit@document->dialog#close']", false
    end
    assert_select "[data-controller='dialog'][data-action='turbo:before-visit@document->dialog#close']"
  end

  test "the mobile drawer's search entry uses its own frame id and skips the global keyboard shortcut" do
    get root_path

    assert_select "turbo-frame#global_search_results"
    assert_select "turbo-frame#global_search_results_mobile"
    assert_select "[data-action='keydown@window->dialog#open']", 1
  end

  test "the sidebar collapse toggle and sign-out button both clear the 36px floor" do
    get root_path

    assert_select "button[data-sidebar-target='panelToggle'].h-\\[var\\(--control-h-sm\\)\\]"
    assert_select "form[action='#{session_path}'] button.h-\\[var\\(--control-h-sm\\)\\]"
  end

  test "the quick-capture trigger renders once for desktop and once for mobile, each with its own panel id" do
    get root_path

    assert_select "#quick_capture_panel"
    assert_select "#quick_capture_panel_mobile"
  end

  test "the quick-capture trigger is hidden when the notes module is disabled" do
    households(:alpha).update!(disabled_modules: [ "notes" ])

    get root_path

    assert_select "#quick_capture_panel", false
    assert_select "#quick_capture_panel_mobile", false
  end
end

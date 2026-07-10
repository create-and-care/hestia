require "test_helper"

class Ui::SidebarComponentTest < ViewComponent::TestCase
  test "renders content inside a nav landmark" do
    render_inline(Ui::SidebarComponent.new) { "Sidebar nav content" }

    assert_selector "div[data-controller='sidebar']"
    assert_selector "aside[data-sidebar-target='panel'] nav", text: "Sidebar nav content"
  end

  test "renders header slot with a toggle button when given" do
    render_inline(Ui::SidebarComponent.new) do |c|
      c.with_header { "My App" }
      "Nav content"
    end

    assert_selector "aside[data-sidebar-target='panel']", text: "My App"
    assert_selector "button[data-action='click->sidebar#toggle'][aria-label='Toggle sidebar']"
  end

  test "the panel toggle button reflects the expanded state via aria-expanded" do
    render_inline(Ui::SidebarComponent.new) do |c|
      c.with_header { "My App" }
      "Nav content"
    end

    assert_selector "button[data-action='click->sidebar#toggle'][data-sidebar-target='panelToggle'][aria-expanded='true']"
  end

  test "omits the header block and toggle button when no header given" do
    render_inline(Ui::SidebarComponent.new) { "Nav content" }

    refute_selector "button[data-action='click->sidebar#toggle']"
  end

  test "renders footer slot when given" do
    render_inline(Ui::SidebarComponent.new) do |c|
      c.with_footer { "Logged in as Jane" }
      "Nav content"
    end

    assert_selector "aside[data-sidebar-target='panel']", text: "Logged in as Jane"
  end

  test "applies a custom class_name to the panel" do
    render_inline(Ui::SidebarComponent.new(class_name: "custom-sidebar")) { "Nav content" }

    assert_selector "aside.custom-sidebar[data-sidebar-target='panel']"
  end

  test "exposes collapsed/expanded width classes for the stimulus controller" do
    render_inline(Ui::SidebarComponent.new) { "Nav content" }

    assert_selector "div[data-controller='sidebar'][data-sidebar-collapsed-class='w-16'][data-sidebar-expanded-class='w-64']"
  end
end

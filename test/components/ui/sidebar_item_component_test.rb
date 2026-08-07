require "test_helper"

class Ui::SidebarItemComponentTest < ViewComponent::TestCase
  test "renders a link with icon medallion and label" do
    render_inline(Ui::SidebarItemComponent.new(icon: "house", label: "Accueil", href: "/"))

    assert_selector "a[href='/'][title='Accueil']"
    assert_selector "span.bg-surface-inset.text-secondary"
    assert_selector "span.min-w-0.flex-1.truncate", text: "Accueil"
  end

  test "renders active state with the active background, semibold label and aria-current" do
    render_inline(Ui::SidebarItemComponent.new(icon: "house", label: "Accueil", href: "/", active: true))

    assert_selector "a[href='/'][aria-current='page'].bg-item-active"
    assert_selector "span.font-semibold", text: "Accueil"
  end

  test "omits aria-current and uses regular weight when not active" do
    render_inline(Ui::SidebarItemComponent.new(icon: "house", label: "Accueil", href: "/"))

    refute_selector "[aria-current]"
    assert_selector "span.font-medium", text: "Accueil"
  end

  test "tints the medallion when a known module is given" do
    render_inline(Ui::SidebarItemComponent.new(icon: "refrigerator", label: "Frigo", href: "/fridge", mod: :fridge))

    assert_selector "span.bg-module-fridge\\/12.text-module-fridge"
  end

  test "collapsed forces the icon-rail recipe: label hidden, row centered, title kept" do
    render_inline(Ui::SidebarItemComponent.new(icon: "house", label: "Accueil", href: "/", collapsed: true))

    assert_selector "a[title='Accueil'].justify-center"
    assert_selector "span.hidden", text: "Accueil"
    assert_selector "span.bg-surface-inset.text-secondary"
  end

  test "hides trailing content when collapsed" do
    render_inline(Ui::SidebarItemComponent.new(icon: "message-circle", label: "Messages", href: "/conversations", collapsed: true)) do |item|
      item.with_trailing { "<span>2</span>".html_safe }
    end

    assert_selector "div.hidden", text: "2"
  end

  test "shows trailing content when expanded" do
    render_inline(Ui::SidebarItemComponent.new(icon: "message-circle", label: "Messages", href: "/conversations")) do |item|
      item.with_trailing { "<span>2</span>".html_safe }
    end

    assert_selector "div:not(.hidden)", text: "2"
  end

  test "the plain variant swaps the medallion for a bare glyph" do
    render_inline(Ui::SidebarItemComponent.new(variant: :plain, icon: "settings", label: "Réglages", href: "/settings"))

    assert_selector "a[href='/settings'] svg"
    refute_selector "span.bg-surface-inset"
    assert_selector "span", text: "Réglages"
  end

  test "the sub variant renders no glyph at all" do
    render_inline(Ui::SidebarItemComponent.new(variant: :sub, label: "Courses", href: "/shopping_lists"))

    refute_selector "svg"
    refute_selector "span.bg-surface-inset"
    assert_selector "a[href='/shopping_lists']", text: "Courses"
  end

  test "each variant sets its own row height" do
    { default: "h-11", plain: "h-10", sub: "h-9" }.each do |variant, height|
      render_inline(Ui::SidebarItemComponent.new(variant: variant, icon: "house", label: "Accueil", href: "/"))

      assert_selector "a.#{height}", count: 1
    end
  end

  test "the sub variant still carries the active state" do
    render_inline(Ui::SidebarItemComponent.new(variant: :sub, label: "Courses", href: "/shopping_lists", active: true))

    assert_selector "a[aria-current='page'].bg-item-active"
    assert_selector "span.font-semibold", text: "Courses"
  end
end

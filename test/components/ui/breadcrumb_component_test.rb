require "test_helper"

class Ui::BreadcrumbComponentTest < ViewComponent::TestCase
  test "renders nav with aria-label" do
    render_inline(Ui::BreadcrumbComponent.new(items: [ [ "Home", "/" ] ]))

    assert_selector "nav[aria-label='Breadcrumb']"
  end

  test "renders links for items with an href" do
    render_inline(Ui::BreadcrumbComponent.new(items: [ [ "Home", "/" ], [ "Settings", "/settings" ] ]))

    assert_selector "a[href='/']", text: "Home"
    assert_selector "a[href='/settings']", text: "Settings"
  end

  test "renders the current page (no href) as plain text with aria-current" do
    render_inline(Ui::BreadcrumbComponent.new(items: [ [ "Home", "/" ], [ "Profile", nil ] ]))

    assert_selector "span[aria-current='page']", text: "Profile"
    refute_selector "a", text: "Profile"
  end

  test "renders a separator between items but not after the last one" do
    render_inline(Ui::BreadcrumbComponent.new(items: [ [ "Home", "/" ], [ "Settings", "/settings" ], [ "Profile", nil ] ]))

    assert_selector "li", count: 3
    assert_selector "span[aria-hidden='true']", text: "/", count: 2
  end

  test "renders nothing when items is empty" do
    render_inline(Ui::BreadcrumbComponent.new)

    assert_selector "ol"
    refute_selector "li"
  end
end

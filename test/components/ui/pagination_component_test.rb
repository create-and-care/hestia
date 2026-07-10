require "test_helper"

class Ui::PaginationComponentTest < ViewComponent::TestCase
  PATH = ->(page) { "/items?page=#{page}" }

  test "renders a nav with aria-label" do
    render_inline(Ui::PaginationComponent.new(current: 1, total: 3, path: PATH))

    assert_selector "nav[aria-label='Pagination']"
  end

  test "renders a link for each page" do
    render_inline(Ui::PaginationComponent.new(current: 1, total: 3, path: PATH))

    assert_selector "a[href='/items?page=1']", text: "1"
    assert_selector "a[href='/items?page=2']", text: "2"
    assert_selector "a[href='/items?page=3']", text: "3"
  end

  test "marks the current page with aria-current and a distinct style" do
    render_inline(Ui::PaginationComponent.new(current: 2, total: 3, path: PATH))

    assert_selector "a[aria-current='page'][href='/items?page=2']"
    assert_selector "a.bg-button-primary[href='/items?page=2']"
    refute_selector "a[aria-current='page'][href='/items?page=1']"
    refute_selector "a[aria-current='page'][href='/items?page=3']"
  end

  test "disables the previous link on the first page" do
    render_inline(Ui::PaginationComponent.new(current: 1, total: 3, path: PATH))

    assert_selector "nav > span:first-child[aria-disabled='true'].pointer-events-none.opacity-50"
    assert_no_selector "a[rel='prev']"
    assert_selector "a[rel='next']"
    refute_selector "a[rel='next'].pointer-events-none"
  end

  test "disables the next link on the last page" do
    render_inline(Ui::PaginationComponent.new(current: 3, total: 3, path: PATH))

    assert_selector "nav > span:last-child[aria-disabled='true'].pointer-events-none.opacity-50"
    assert_no_selector "a[rel='next']"
    refute_selector "a[rel='prev'].pointer-events-none"
  end

  test "renders a disabled boundary control with no href and not focusable" do
    render_inline(Ui::PaginationComponent.new(current: 1, total: 3, path: PATH))

    assert_selector "span[aria-disabled='true']"
    assert_no_selector "span[aria-disabled='true'] a"
    assert_no_selector "[aria-disabled='true'][href]"
  end

  test "neither prev nor next is disabled on a middle page" do
    render_inline(Ui::PaginationComponent.new(current: 2, total: 3, path: PATH))

    refute_selector "a[rel='prev'].pointer-events-none"
    refute_selector "a[rel='next'].pointer-events-none"
  end
end

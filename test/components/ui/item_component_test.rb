require "test_helper"

class Ui::ItemComponentTest < ViewComponent::TestCase
  test "renders a div when no href is given" do
    render_inline(Ui::ItemComponent.new) do |item|
      item.with_title { "Title" }
    end

    assert_selector "div.flex.items-center"
    refute_selector "a"
  end

  test "renders an anchor with hover styling when href is given" do
    render_inline(Ui::ItemComponent.new(href: "/things/1")) do |item|
      item.with_title { "Title" }
    end

    assert_selector "a[href='/things/1'].hover\\:bg-surface-hover.cursor-pointer"
  end

  test "renders active state with the active background, semibold title and aria-current" do
    render_inline(Ui::ItemComponent.new(href: "/things/1", active: true)) do |item|
      item.with_title { "Title" }
    end

    assert_selector "a[href='/things/1'][aria-current='page'].bg-item-active"
    assert_selector "p.font-semibold", text: "Title"
    refute_selector ".hover\\:bg-surface-hover"
  end

  test "omits aria-current and uses regular weight when not active" do
    render_inline(Ui::ItemComponent.new(href: "/things/1")) do |item|
      item.with_title { "Title" }
    end

    refute_selector "[aria-current]"
    assert_selector "p.font-medium", text: "Title"
  end

  test "renders leading, title, description and trailing slots" do
    render_inline(Ui::ItemComponent.new) do |item|
      item.with_leading { "L" }
      item.with_title { "Title" }
      item.with_description { "Description" }
      item.with_trailing { "T" }
    end

    assert_selector "p", text: "Title"
    assert_selector "p", text: "Description"
    assert_text "L"
    assert_text "T"
  end

  test "omits slots that are not provided" do
    render_inline(Ui::ItemComponent.new) do |item|
      item.with_title { "Only a title" }
    end

    assert_selector "p", count: 1
    assert_selector "p", text: "Only a title"
  end
end

require "test_helper"

class Ui::TableComponentTest < ViewComponent::TestCase
  test "renders headers and rows" do
    render_inline(Ui::TableComponent.new(
      headers: [ "Name", "Email" ],
      rows: [ [ "Ada", "ada@example.com" ], [ "Grace", "grace@example.com" ] ]
    ))

    assert_selector "table thead th", count: 2
    assert_selector "th", text: "Name"
    assert_selector "table tbody tr", count: 2
    assert_selector "td", text: "ada@example.com"
  end

  test "header cells declare scope=col for screen readers" do
    render_inline(Ui::TableComponent.new(headers: [ "Name", "Email" ], rows: []))

    assert_selector "th[scope='col']", count: 2
  end

  test "omits the header row entirely when there are no headers" do
    render_inline(Ui::TableComponent.new(rows: [ [ "Ada" ] ]))

    refute_selector "thead"
    assert_selector "td", text: "Ada"
  end

  test "renders an empty body when there are no rows" do
    render_inline(Ui::TableComponent.new(headers: [ "Name" ]))

    assert_selector "thead th", text: "Name"
    refute_selector "tbody tr"
  end
end

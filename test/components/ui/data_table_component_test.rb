require "test_helper"

class Ui::DataTableComponentTest < ViewComponent::TestCase
  HEADERS = %w[Name Age].freeze
  ROWS = [ %w[Alice 30], %w[Bob 25], %w[Carol 22] ].freeze

  test "renders one header cell per header, indexed for the sort action" do
    render_inline(Ui::DataTableComponent.new(headers: HEADERS, rows: ROWS))

    assert_selector "th[data-data-table-target='header']", count: 2
    assert_selector "th[data-index='0']", text: "Name"
    assert_selector "th[data-index='1']", text: "Age"
    assert_selector "th span[data-data-table-target='arrow'][data-index='0']"
  end

  test "renders the sortable header label as a real button, keyboard-activatable" do
    render_inline(Ui::DataTableComponent.new(headers: HEADERS, rows: ROWS))

    assert_selector "th button[type='button'][data-action='click->data-table#sort'][data-index='0']", text: "Name"
    assert_selector "th button[type='button'][data-action='click->data-table#sort'][data-index='1']", text: "Age"
  end

  test "defaults aria-sort to none on every header" do
    render_inline(Ui::DataTableComponent.new(headers: HEADERS, rows: ROWS))

    assert_selector "th[data-index='0'][aria-sort='none']"
    assert_selector "th[data-index='1'][aria-sort='none']"
  end

  test "renders one row and cell set per data row" do
    render_inline(Ui::DataTableComponent.new(headers: HEADERS, rows: ROWS))

    assert_selector "tr[data-data-table-target='row']", count: 3
    assert_selector "td", text: "Alice"
    assert_selector "td", text: "25"
    assert_selector "td", text: "22"
  end

  test "renders the filter input wired to the filter action" do
    render_inline(Ui::DataTableComponent.new(headers: HEADERS, rows: ROWS))

    assert_selector "input[type='search'][data-data-table-target='filterInput'][data-action='input->data-table#filter']"
  end

  test "renders pagination controls and forwards the configured page size" do
    render_inline(Ui::DataTableComponent.new(headers: HEADERS, rows: ROWS, page_size: 2))

    assert_selector "div[data-controller='data-table'][data-data-table-page-size-value='2']"
    assert_selector "span[data-data-table-target='pageLabel']"
    # Through I18n, not the French literal the component used to hardcode.
    assert_selector "button[data-data-table-target='prevButton'][data-action='click->data-table#previous']", text: I18n.t("ui.data_table.previous")
    assert_selector "button[data-data-table-target='nextButton'][data-action='click->data-table#next']", text: I18n.t("ui.data_table.next")
  end

  test "defaults the page size to 5" do
    render_inline(Ui::DataTableComponent.new(headers: HEADERS, rows: ROWS))

    assert_selector "div[data-data-table-page-size-value='5']"
  end

  test "renders with no rows without raising" do
    render_inline(Ui::DataTableComponent.new(headers: HEADERS, rows: []))

    assert_selector "th", count: 2
    assert_no_selector "tr[data-data-table-target='row']"
  end
end

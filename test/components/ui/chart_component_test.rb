require "test_helper"

class Ui::ChartComponentTest < ViewComponent::TestCase
  test "renders one bar per data point with its label" do
    render_inline(Ui::ChartComponent.new(data: [ [ "Jan", 42 ], [ "Feb", 73 ] ]))

    assert_selector "div.flex.items-end", count: 1
    assert_selector "span", text: "Jan"
    assert_selector "span", text: "Feb"
  end

  test "scales bar height relative to the maximum value in the series" do
    render_inline(Ui::ChartComponent.new(data: [ [ "Jan", 50 ], [ "Feb", 100 ] ]))

    assert_selector "div[style*='height: 50.0%']"
    assert_selector "div[style*='height: 100.0%']"
  end

  test "applies the configured container height in pixels" do
    render_inline(Ui::ChartComponent.new(data: [ [ "Jan", 1 ] ], height: 240))

    assert_selector "div[style*='height: 240px']"
  end

  test "defaults to a 160px container height" do
    render_inline(Ui::ChartComponent.new(data: [ [ "Jan", 1 ] ]))

    assert_selector "div[style*='height: 160px']"
  end

  test "cycles through the color palette for series longer than the palette" do
    data = (1..6).map { |n| [ "M#{n}", n ] }

    render_inline(Ui::ChartComponent.new(data: data))

    assert_selector "div.bg-module-tasks", count: 2 # index 0 and index 5 both wrap to the first color
  end

  test "each bar carries an accessible label combining its category and value" do
    render_inline(Ui::ChartComponent.new(data: [ [ "Jan", 42 ], [ "Feb", 73 ] ]))

    assert_selector "div[role='img'][aria-label='Jan : 42']"
    assert_selector "div[role='img'][aria-label='Feb : 73']"
  end

  test "renders without raising for an empty dataset" do
    render_inline(Ui::ChartComponent.new(data: []))

    assert_selector "div.flex.items-end"
    assert_no_selector "span"
  end
end

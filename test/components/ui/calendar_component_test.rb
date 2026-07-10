require "test_helper"

class Ui::CalendarComponentTest < ViewComponent::TestCase
  test "renders the controller root with today's month as the initial selected value" do
    render_inline(Ui::CalendarComponent.new(selected: "2026-07-08"))

    assert_selector "div[data-controller='calendar'][data-calendar-selected-value='2026-07-08']"
  end

  test "renders navigation buttons with accessible labels" do
    render_inline(Ui::CalendarComponent.new)

    assert_selector "button[data-action='click->calendar#previous'][aria-label='Previous month']"
    assert_selector "button[data-action='click->calendar#next'][aria-label='Next month']"
  end

  test "renders the label and grid targets that the Stimulus controller fills in on connect" do
    render_inline(Ui::CalendarComponent.new)

    assert_selector "p[data-calendar-target='label']"
    assert_selector "div[data-calendar-target='grid']"
  end

  test "renders the grid target with role=grid for assistive tech" do
    render_inline(Ui::CalendarComponent.new)

    assert_selector "div[data-calendar-target='grid'][role='grid']"
  end

  test "renders a hidden input wired to the calendar target when a form field name is given" do
    render_inline(Ui::CalendarComponent.new(name: "due_on", selected: "2026-07-08"))

    assert_selector "input[type='hidden'][name='due_on'][value='2026-07-08'][data-calendar-target='input']", visible: false
  end

  test "omits the hidden input entirely when no name is given" do
    render_inline(Ui::CalendarComponent.new)

    assert_no_selector "input[data-calendar-target='input']", visible: false
  end
end

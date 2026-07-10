require "test_helper"

class Ui::DatePickerComponentTest < ViewComponent::TestCase
  test "shows the placeholder in the trigger label when nothing is selected" do
    render_inline(Ui::DatePickerComponent.new)

    assert_selector "span[data-date-picker-target='label']", text: "Choisir une date"
  end

  test "supports a custom placeholder" do
    render_inline(Ui::DatePickerComponent.new(placeholder: "Pick a day"))

    assert_selector "span[data-date-picker-target='label']", text: "Pick a day"
  end

  test "shows the selected date in the trigger label instead of the placeholder" do
    render_inline(Ui::DatePickerComponent.new(selected: "2026-07-08"))

    assert_selector "span[data-date-picker-target='label']", text: "2026-07-08"
  end

  test "wires the popover and date-picker controllers to the calendar's select event" do
    render_inline(Ui::DatePickerComponent.new)

    assert_selector "div[data-controller='popover date-picker'][data-action='calendar:select->popover#hide calendar:select->date-picker#select']"
    assert_selector "div[data-popover-target='trigger'][data-action='click->popover#toggle']"
  end

  test "renders the popover panel closed and hidden by default" do
    render_inline(Ui::DatePickerComponent.new)

    assert_selector "div[data-popover-target='panel'][data-state='closed']", visible: false
    assert_selector "div[data-popover-target='panel'][hidden]", visible: false
  end

  test "composes a real Ui::CalendarComponent inside the panel, forwarding name and selected" do
    render_inline(Ui::DatePickerComponent.new(name: "due_on", selected: "2026-07-08"))

    assert_selector "div[data-popover-target='panel'] div[data-controller='calendar'][data-calendar-selected-value='2026-07-08']", visible: false
    assert_selector "input[type='hidden'][name='due_on'][value='2026-07-08']", visible: false
  end
end

require "test_helper"

class Ui::SliderComponentTest < ViewComponent::TestCase
  test "defaults to a 0-100 range with a value of 50 and a step of 1" do
    render_inline(Ui::SliderComponent.new)

    assert_selector "input[type='range'][min='0'][max='100'][value='50'][step='1']"
  end

  test "renders custom min/max/value/step attributes" do
    render_inline(Ui::SliderComponent.new(min: 10, max: 90, value: 40, step: 5))

    assert_selector "input[type='range'][min='10'][max='90'][value='40'][step='5']"
  end

  test "sets the input's name when given, for form submission" do
    render_inline(Ui::SliderComponent.new(name: "volume", value: 75))

    assert_selector "input[type='range'][name='volume'][value='75']"
  end

  test "wires the input and output targets to the slider controller" do
    render_inline(Ui::SliderComponent.new)

    assert_selector "div[data-controller='slider']"
    assert_selector "input[data-slider-target='input'][data-action='input->slider#update']"
    assert_selector "output[data-slider-target='output']"
  end

  test "sets aria-label on the input when a label is given" do
    render_inline(Ui::SliderComponent.new(label: "Volume"))

    assert_selector "input[type='range'][aria-label='Volume']"
  end

  test "omits aria-label entirely when no label is given" do
    render_inline(Ui::SliderComponent.new)

    assert_no_selector "input[aria-label]"
  end
end

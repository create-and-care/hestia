require "test_helper"

class Ui::InputOtpComponentTest < ViewComponent::TestCase
  test "renders default with 6 boxes" do
    render_inline(Ui::InputOtpComponent.new(name: "otp"))

    assert_selector "div[data-controller='input-otp']"
    assert_selector "input[data-input-otp-target='box']", count: 6
    assert_selector "input[type='hidden'][name='otp'][data-input-otp-target='input']", visible: :all
  end

  test "renders a custom number of boxes" do
    render_inline(Ui::InputOtpComponent.new(name: "otp", length: 4))

    assert_selector "input[data-input-otp-target='box']", count: 4
  end

  test "each box is a single-character numeric text input" do
    render_inline(Ui::InputOtpComponent.new(name: "otp", length: 2))

    assert_selector "input[type='text'][inputmode='numeric'][maxlength='1'][data-input-otp-target='box']", count: 2
  end

  test "boxes wire up type, navigate, and paste actions" do
    render_inline(Ui::InputOtpComponent.new(name: "otp"))

    assert_selector "input[data-action*='input->input-otp#type']"
    assert_selector "input[data-action*='keydown->input-otp#navigate']"
    assert_selector "input[data-action*='paste->input-otp#paste']"
  end

  test "each box has a positional aria-label for screen readers" do
    render_inline(Ui::InputOtpComponent.new(name: "otp", length: 3))

    assert_selector "input[data-input-otp-target='box'][aria-label='Chiffre 1 sur 3']"
    assert_selector "input[data-input-otp-target='box'][aria-label='Chiffre 2 sur 3']"
    assert_selector "input[data-input-otp-target='box'][aria-label='Chiffre 3 sur 3']"
  end

  test "only the first box carries autocomplete one-time-code for OTP autofill" do
    render_inline(Ui::InputOtpComponent.new(name: "otp", length: 3))

    assert_selector "input[data-input-otp-target='box'][autocomplete='one-time-code']", count: 1
    assert_selector "input[data-input-otp-target='box'][aria-label='Chiffre 1 sur 3'][autocomplete='one-time-code']"
  end
end

require "application_system_test_case"

class FillInRetryTest < ApplicationSystemTestCase
  # The dropped keystrokes fill_in recovers from are a driver-level accident
  # that can't be provoked on demand, so this stands in for them: a listener
  # that empties the field as it is typed into, and lets go the moment the
  # field is blurred. The first attempt therefore ends exactly where the
  # failure screenshots did — field untouched, no error raised — and only a
  # retry that re-focuses the field can land the value.
  test "fill_in retries a first attempt whose keystrokes never landed" do
    visit new_session_path

    page.execute_script(<<~JS)
      const field = document.getElementById("email_address")
      const swallow = () => { field.value = "" }
      field.addEventListener("input", swallow)
      field.addEventListener("blur", () => field.removeEventListener("input", swallow), { once: true })
    JS

    fill_in "email_address", with: users(:one).email_address

    assert_field "email_address", with: users(:one).email_address
  end

  # And when every attempt is dropped rather than just the first — the state CI
  # reached on the menu's "Add a meal" dialog — the JS fallback is what lands
  # the value. Preventing the default on keydown swallows real keystrokes for
  # good, so all three attempts leave the field untouched, while a programmatic
  # set goes through: exactly the asymmetry the fallback rests on.
  test "fill_in sets the value from JS when no attempt's keystrokes land" do
    visit new_session_path

    page.execute_script(<<~JS)
      document.getElementById("email_address")
        .addEventListener("keydown", (event) => event.preventDefault())
    JS

    fill_in "email_address", with: users(:one).email_address

    assert_field "email_address", with: users(:one).email_address
  end
end

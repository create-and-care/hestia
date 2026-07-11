module SystemTestHelper
  # Selenium's native WebDriver click occasionally never triggers a
  # button_to submit button's underlying form in this environment — no
  # request ever reaches the server, with no error raised on the Capybara
  # side either (confirmed by comparing it side-by-side with a JS-dispatched
  # submit on the exact same element, which works reliably every time).
  # Submitting the form via JS is otherwise a faithful simulation of the
  # click from Turbo's perspective (Turbo intercepts the form's "submit"
  # event, not a "click" on the button), so this is a safe, general
  # replacement for `click_on` on any button_to-rendered submit button.
  def submit_button_to(text)
    button = find(:button, text)
    page.execute_script('arguments[0].closest("form").requestSubmit(arguments[0])', button.native)
  end
end

ActiveSupport.on_load(:action_dispatch_system_test_case) do
  include SystemTestHelper
end

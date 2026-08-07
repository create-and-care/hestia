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

  # A <dialog> becomes scriptable the instant dialog#open flips data-state to
  # "open", but it then spends 200ms fading and scaling in (animate-in,
  # zoom-in-95, fade-in-0). WebDriver silently drops send_keys aimed inside a
  # dialog that is still animating: no error is raised, the keystrokes reach
  # no element at all, and the failure surfaces much later and somewhere else
  # — "the dialog never closed", because requestSubmit hit a required field
  # that was still empty. So asserting the dialog is open is not enough to
  # start typing in it; wait for the entrance to finish, which is all a human
  # does by being slower than the machine.
  #
  # Only the dialog's own animations are awaited, deliberately: a subtree walk
  # would also pick up an infinite one (a loading skeleton's animate-pulse)
  # and wait for a promise that never settles.
  def assert_dialog_open(selector = "dialog[data-state='open']")
    assert_selector selector
    page.evaluate_async_script(<<~JS, selector)
      const done = arguments[arguments.length - 1]
      const dialog = document.querySelector(arguments[0])
      const animations = dialog ? dialog.getAnimations() : []
      Promise.allSettled(animations.map((animation) => animation.finished)).then(() => done())
    JS
  end
end

ActiveSupport.on_load(:action_dispatch_system_test_case) do
  include SystemTestHelper
end

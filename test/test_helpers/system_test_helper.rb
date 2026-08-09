module SystemTestHelper
  # Selenium's native click occasionally never reaches the page in this
  # environment: no request is made, no error is raised, and the failure
  # surfaces much later as an assertion timing out against a page that simply
  # never changed. test_system lost a run to exactly that on the Waste view
  # toggle — an ordinary <a href> whose failure screenshot shows the page
  # still in list mode, ten seconds after the click. Dispatching the click
  # from JS targets the element itself instead of a point on the screen, so
  # it cannot land next to it, and Turbo sees the same event either way.
  def click_element(node_or_selector)
    node = node_or_selector.respond_to?(:native) ? node_or_selector : find(node_or_selector)
    page.execute_script("arguments[0].click()", node.native)
  end

  # The same failure, on the specific case of a button_to submit button: no
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

  # The same drop again, on keystrokes: `fill_in` reports success on a field
  # it never actually typed into, and the run fails ten seconds later on some
  # unrelated assertion. The failure screenshots are unambiguous about what
  # happened — the field is still holding the value it had beforehand, with
  # that value selected. Capybara clears a field by JS-selecting its contents
  # and then sending the replacement as real keystrokes (see #set_text in
  # capybara/selenium/node.rb), and only the second half goes missing.
  # test_system lost runs to this on /vehicles/new (name left empty) and on
  # the task edit modal (title left as it was); it is rare here and frequent
  # on CI, and it lands on whichever test happens to type first rather than
  # on any one page being broken.
  #
  # Reading the field back is what makes that recoverable instead of
  # mysterious. The blur is what makes the next attempt a real retry rather
  # than a replay of the last: WebDriver runs its own focusing step only for
  # a field that isn't already document.activeElement, and the select() above
  # leaves it focused. Three attempts because two were not enough — a run
  # under load dropped both, and left the task edit modal's title sitting at
  # its original value. If none of them land, fail here, on the line that did
  # the typing and naming the field, rather than somewhere else much later.
  def fill_in(locator = nil, **options)
    lookup = options.except(:fill_options, :currently_with)

    3.times do
      super
      return if has_field?(locator, **lookup, wait: 2)

      page.execute_script("document.activeElement && document.activeElement.blur()")
    end

    assert_field locator, **lookup
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

require "test_helper"

class Ui::AlertDialogComponentTest < ViewComponent::TestCase
  test "renders trigger, title, description, cancel and confirm actions" do
    render_inline(
      Ui::AlertDialogComponent.new(title: "Delete account?", description: "This action is permanent.")
    ) do |c|
      c.with_trigger { "Delete" }
    end

    assert_selector "[data-controller='dialog']"
    assert_selector "[data-action='click->dialog#open']", text: "Delete"
    assert_selector "dialog[data-dialog-target='dialog'][data-state='closed']"
    assert_selector "dialog[role='alertdialog']"
    assert_selector "h2", text: "Delete account?"
    assert_selector "p", text: "This action is permanent."
    assert_selector "button[data-action='click->dialog#close']", text: "Cancel"
    assert_selector "button[data-action='click->dialog#close']", text: "Continue"
  end

  test "uses custom cancel and confirm labels" do
    render_inline(
      Ui::AlertDialogComponent.new(title: "Sign out?", cancel_label: "Stay", confirm_label: "Sign out")
    ) do |c|
      c.with_trigger { "Log out" }
    end

    assert_selector "button", text: "Stay"
    assert_selector "button", text: "Sign out"
  end

  test "omits the description paragraph when none is given" do
    render_inline(Ui::AlertDialogComponent.new(title: "Are you sure?")) do |c|
      c.with_trigger { "Open" }
    end

    refute_selector "p"
  end

  test "defaults confirm/cancel labels to Continue/Cancel" do
    render_inline(Ui::AlertDialogComponent.new(title: "Proceed?")) do |c|
      c.with_trigger { "Open" }
    end

    assert_selector "button", text: "Cancel"
    assert_selector "button", text: "Continue"
  end

  test "renders a real form submit for the confirm action when given a confirm_url" do
    render_inline(
      Ui::AlertDialogComponent.new(title: "Delete household?", confirm_label: "Delete", confirm_url: "/households/1", confirm_method: :delete)
    ) do |c|
      c.with_trigger { "Delete household" }
    end

    assert_selector "form[action='/households/1']" do
      assert_selector "input[name='_method'][value='delete']", visible: false
      assert_selector "button[type='submit']", text: "Delete"
    end
    refute_selector "button[data-action='click->dialog#close']", text: "Delete"
  end
end

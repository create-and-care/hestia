require "test_helper"

# The app has ~59 `data: { turbo_confirm: … }` call sites. Turbo's default for
# those is the browser's own confirm() — unstyleable, theme-blind, and nothing
# like the design system. One dialog mounted per layout is handed to
# Turbo.config.forms.confirm so all of them get the design-system dialog.
class ConfirmDialogTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "the standard layout mounts the confirm dialog" do
    get tasks_path
    assert_response :success
    assert_select "[data-controller='confirm'] dialog[role='alertdialog'][data-confirm-target='dialog']"
  end

  test "the minimal layout mounts it too" do
    get cook_recipe_path(recipes(:alpha_pancakes))
    assert_response :success
    assert_select "[data-controller='confirm'] dialog[role='alertdialog']"
  end

  test "it carries the message slot and both actions the controller drives" do
    get tasks_path
    assert_select "[data-confirm-target='message']"
    assert_select "[data-action='click->confirm#accept'][data-confirm-target='accept']"
    assert_select "[data-action='click->confirm#cancel']"
  end

  # role="alertdialog" is not self-labelling: without these the dialog announces
  # as "alert dialog" and nothing more, on the one screen where the message is
  # the decision being made.
  test "it is named and described by the elements the controller writes into" do
    get tasks_path

    assert_select "dialog#global_confirm_dialog[aria-labelledby='global_confirm_dialog_title'][aria-describedby='global_confirm_dialog_message']"
    assert_select "#global_confirm_dialog_title[data-confirm-target='title']"
    assert_select "#global_confirm_dialog_message[data-confirm-target='message']"
  end

  # A page still carrying turbo_confirm is the whole point — those call sites are
  # deliberately left alone, and the dialog is what changes their appearance.
  test "existing turbo_confirm call sites keep working through it" do
    get fridge_path
    assert_response :success
    assert_match(/data-turbo-confirm=/, @response.body)
    assert_select "[data-controller='confirm']"
  end
end

require "test_helper"

class TaskRemindersControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create adds a reminder for the current user" do
    task = tasks(:alpha_dishes)
    assert_difference -> { task.task_reminders.count }, 1 do
      post task_task_reminders_path(task), params: { task_reminder: { remind_at: 1.day.from_now } }
    end
    assert_redirected_to edit_task_path(task)
    assert_equal users(:one), task.task_reminders.last.user
  end

  test "ignores a user_id from another household and falls back to the current user" do
    task = tasks(:alpha_dishes)
    post task_task_reminders_path(task), params: { task_reminder: { remind_at: 1.day.from_now, user_id: users(:two).id } }
    assert_equal users(:one), task.task_reminders.last.user
  end

  test "destroy removes a reminder" do
    task = tasks(:alpha_dishes)
    reminder = task.task_reminders.create!(remind_at: 1.day.from_now, user: users(:one))
    assert_difference -> { task.task_reminders.count }, -1 do
      delete task_task_reminder_path(task, reminder)
    end
    assert_redirected_to edit_task_path(task)
  end

  test "cannot create a reminder on another household's task" do
    task = tasks(:beta_report)
    assert_no_difference -> { TaskReminder.count } do
      post task_task_reminders_path(task), params: { task_reminder: { remind_at: 1.day.from_now } }
    end
    assert_response :not_found
  end

  test "cannot destroy a reminder on another household's task" do
    task = tasks(:beta_report)
    reminder = task.task_reminders.create!(remind_at: 1.day.from_now, user: users(:two))
    delete task_task_reminder_path(task, reminder)
    assert_response :not_found
  end
end

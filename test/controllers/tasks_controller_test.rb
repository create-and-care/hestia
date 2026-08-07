require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "index requires authentication" do
    sign_out
    get tasks_path
    assert_redirected_to new_session_path
  end

  test "index shows the household's tasks, grouped by due date by default" do
    get tasks_path
    assert_response :success
    assert_includes @response.body, "Faire la vaisselle"
    assert_not_includes @response.body, "Rapport" # beta's task
    assert_select "[id^='tasks_agenda_']"
    assert_select "#tasks_uncategorized", count: 0
  end

  test "the board is still available, and the chosen view is remembered" do
    get tasks_path(view: "board")
    assert_response :success
    assert_select "#tasks_uncategorized"

    get tasks_path # no explicit view this time
    assert_response :success
    assert_select "#tasks_uncategorized"
  end

  test "an unknown view falls back to the agenda" do
    get tasks_path(view: "gantt")
    assert_response :success
    assert_select "[id^='tasks_agenda_']"
  end

  test "the agenda buckets an overdue task apart from one due later" do
    households(:alpha).tasks.create!(title: "En retard", due_on: 3.days.ago.to_date)
    households(:alpha).tasks.create!(title: "Plus tard", due_on: 3.months.from_now.to_date)

    get tasks_path(view: "agenda")

    assert_response :success
    assert_select "#tasks_agenda_overdue" do
      assert_select "*", text: /En retard/
    end
    assert_select "#tasks_agenda_later"
  end

  test "a completed task drops to the done bucket whatever its due date" do
    households(:alpha).tasks.create!(title: "Faite mais en retard", due_on: 3.days.ago.to_date, done: true)

    get tasks_path(view: "agenda")

    assert_response :success
    assert_select "#tasks_agenda_done" do
      assert_select "*", text: /Faite mais en retard/
    end
  end

  test "task deletion uses the design-system alert dialog instead of a native confirm" do
    get tasks_path
    assert_response :success
    assert_select "dialog[role='alertdialog']"
    assert_no_match(/data-turbo-confirm="#{Regexp.escape(I18n.t("tasks.task.delete_confirm"))}"/, @response.body)
  end

  test "category deletion uses the design-system alert dialog too" do
    get tasks_path(view: "board")
    assert_response :success
    assert_select "dialog[role='alertdialog']", text: /#{Regexp.escape(I18n.t("tasks.index.delete_category_confirm"))}/
    assert_no_match(/data-turbo-confirm="#{Regexp.escape(I18n.t("tasks.index.delete_category_confirm"))}"/, @response.body)
  end

  # The chips duplicated every category the board already names, purely to hang
  # a delete button off each one.
  test "the category chip row is gone, leaving only the add form" do
    get tasks_path(view: "board")
    assert_response :success

    assert_select "form[action=?]", task_categories_path
    # Deleting a category is now reachable only from its column heading's alert
    # dialog, not from a row of chips repeating every category name.
    assert_select "form[action=?]", task_category_path(task_categories(:alpha_home)), count: 1
    assert_select "dialog[role='alertdialog'] form[action=?]", task_category_path(task_categories(:alpha_home))
  end

  test "search filters the tasks" do
    get tasks_path(q: "vaisselle")
    assert_response :success
    assert_includes @response.body, "Faire la vaisselle"
  end

  test "search also matches the description" do
    tasks(:alpha_call).update!(description: "Prendre rendez-vous urgent")
    get tasks_path(q: "urgent")
    assert_includes @response.body, "Appeler le médecin"
  end

  test "search hides categories that have no matching tasks" do
    get tasks_path(q: "vaisselle", view: "board")
    assert_response :success
    assert_select "#tasks_category_#{task_categories(:alpha_home).id}"
    assert_select "#tasks_uncategorized", count: 0
  end

  test "create passes the description through instead of dropping it" do
    post tasks_path, params: { task: { title: "Nouvelle", description: "Des détails" } }, as: :turbo_stream
    assert_equal "Des détails", Task.find_by!(title: "Nouvelle").description
  end

  test "create with a category and an assignee" do
    assert_difference -> { households(:alpha).tasks.count }, 1 do
      post tasks_path, params: { task: {
        title: "Balayer", task_category_id: task_categories(:alpha_home).id, assignee_id: users(:one).id
      } }, as: :turbo_stream
    end
    assert_response :success
    task = Task.find_by!(title: "Balayer")
    assert_equal task_categories(:alpha_home), task.task_category
    assert_equal users(:one), task.assignee
  end

  test "create ignores an assignee outside the household" do
    post tasks_path, params: { task: { title: "Intrus", assignee_id: users(:two).id } }, as: :turbo_stream
    assert_nil Task.find_by(title: "Intrus").assignee_id
  end

  test "toggle flips the done state" do
    task = tasks(:alpha_dishes)
    patch toggle_task_path(task), as: :turbo_stream
    assert_response :success
    assert task.reload.done
  end

  test "update" do
    task = tasks(:alpha_dishes)
    patch task_path(task), params: { task: { title: "Vaisselle du soir" } }
    assert_redirected_to tasks_path
    assert_equal "Vaisselle du soir", task.reload.title
  end

  test "update via turbo_stream returns no content so the modal can close, relying on the real-time stream to refresh the card" do
    task = tasks(:alpha_dishes)
    patch task_path(task), params: { task: { title: "Vaisselle du matin" } }, as: :turbo_stream
    assert_response :no_content
    assert_equal "Vaisselle du matin", task.reload.title
  end

  test "update preserves an emoji set outside the web form, since its input was removed" do
    task = tasks(:alpha_dishes)
    task.update_column(:emoji, "🧽")
    patch task_path(task), params: { task: { title: "Vaisselle du matin" } }
    assert_equal "🧽", task.reload.emoji
  end

  test "edit no longer offers an emoji input" do
    get edit_task_path(tasks(:alpha_dishes))
    assert_response :success
    assert_select "input[name='task[emoji]']", count: 0
  end

  test "edit shows a breadcrumb back to tasks instead of a back link" do
    get edit_task_path(tasks(:alpha_dishes))
    assert_select "nav a[href=?]", tasks_path
  end

  test "edit shows the reminders/discuss link only when loaded as a modal frame" do
    task = tasks(:alpha_dishes)
    get edit_task_path(task), headers: { "Turbo-Frame" => "edit_task_#{task.id}" }
    assert_select "a[data-turbo-frame='_top']"

    get edit_task_path(task)
    assert_select "a[data-turbo-frame='_top']", count: 0
  end

  test "index offers a lazy-loaded edit modal for each task, scoped to the task's own frame" do
    task = tasks(:alpha_dishes)
    get tasks_path
    assert_select "turbo-frame##{ActionView::RecordIdentifier.dom_id(task, :edit)}[src=?]", edit_task_path(task)
  end

  test "destroy" do
    task = tasks(:alpha_dishes)
    delete task_path(task), as: :turbo_stream
    assert_response :success
    assert_not Task.exists?(task.id)
  end

  test "cannot touch another household's task" do
    delete task_path(tasks(:beta_report))
    assert_response :not_found
  end

  test "move_up swaps position with the previous task in the same column" do
    first = tasks(:alpha_dishes) # alpha_home, position 0
    second = households(:alpha).tasks.create!(title: "Ranger", task_category: task_categories(:alpha_home), position: 5)

    patch move_up_task_path(second)

    assert_equal 0, second.reload.position
    assert_equal 5, first.reload.position
  end

  test "move_up does nothing for the first task in its column" do
    first = tasks(:alpha_dishes)
    patch move_up_task_path(first)
    assert_equal 0, first.reload.position
  end

  test "move_down swaps position with the next task in the same column" do
    first = tasks(:alpha_dishes) # alpha_home, position 0
    second = households(:alpha).tasks.create!(title: "Ranger", task_category: task_categories(:alpha_home), position: 5)

    patch move_down_task_path(first)

    assert_equal 5, first.reload.position
    assert_equal 0, second.reload.position
  end

  test "sort by due_date reorders unfinished tasks within a column without touching other columns" do
    no_due = households(:alpha).tasks.create!(title: "Sans échéance", task_category: task_categories(:alpha_home), position: 0)
    with_due = households(:alpha).tasks.create!(title: "Avec échéance", task_category: task_categories(:alpha_home),
      due_on: 1.day.from_now, position: 10)
    tasks(:alpha_dishes).update!(position: 20) # also alpha_home, due in 3 days — should sort after with_due

    post sort_tasks_path, params: { by: "due_date" }

    assert_equal 0, with_due.reload.position
    assert_equal 1, tasks(:alpha_dishes).reload.position
    assert_equal 2, no_due.reload.position
  end

  test "sort ignores an unknown 'by' value" do
    post sort_tasks_path, params: { by: "nonsense" }
    assert_redirected_to tasks_path
  end

  test "edit offers a discuss-this-task shortcut into Messages" do
    get edit_task_path(tasks(:alpha_dishes))
    assert_response :success
    assert_select "form[action^=?]", discuss_conversations_path
  end

  test "edit offers existing subject-less conversations in the discuss dialog" do
    get edit_task_path(tasks(:alpha_dishes))
    assert_select "select[name='conversation_id']"
  end
end

require "test_helper"

class PlantCareTasksControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create requires authentication" do
    sign_out
    plant = plants(:alpha_rose)
    post plant_plant_care_tasks_path(plant), params: { plant_care_task: { care_type: "watering", frequency: "daily" } }
    assert_redirected_to new_session_path
  end

  test "create adds a care task to the household's plant" do
    plant = plants(:alpha_rose)
    assert_difference -> { plant.plant_care_tasks.count }, 1 do
      post plant_plant_care_tasks_path(plant), params: { plant_care_task: { care_type: "watering", frequency: "daily", interval: 2 } }
    end
    assert_redirected_to plant_path(plant)
  end

  test "create with a blank care_type redirects with an error instead of failing silently" do
    plant = plants(:alpha_rose)
    assert_no_difference -> { PlantCareTask.count } do
      post plant_plant_care_tasks_path(plant), params: { plant_care_task: { care_type: "", frequency: "daily" } }
    end
    assert_redirected_to plant_path(plant)
    assert_not_nil flash[:alert]
  end

  test "cannot add a care task to another household's plant" do
    plant = plants(:beta_plant)
    assert_no_difference -> { PlantCareTask.count } do
      post plant_plant_care_tasks_path(plant), params: { plant_care_task: { care_type: "watering", frequency: "daily" } }
    end
    assert_response :not_found
  end

  test "update changes the frequency" do
    task = plant_care_tasks(:alpha_rose_repotting)
    patch plant_plant_care_task_path(task.plant, task), params: { plant_care_task: { frequency: "monthly" } }
    assert_redirected_to plant_path(task.plant)
    assert_equal "monthly", task.reload.frequency
  end

  test "destroy removes the care task" do
    task = plant_care_tasks(:alpha_rose_repotting)
    delete plant_plant_care_task_path(task.plant, task)
    assert_redirected_to plant_path(task.plant)
    assert_not PlantCareTask.exists?(task.id)
  end

  test "complete advances the due date and logs a completion" do
    task = plant_care_tasks(:alpha_rose_watering_overdue) # daily, interval 1
    assert_difference -> { task.plant_care_completions.count }, 1 do
      post complete_plant_plant_care_task_path(task.plant, task)
    end
    assert_redirected_to plant_path(task.plant)
    assert_equal Date.current + 1.day, task.reload.next_due_on
  end

  test "cannot destroy another household's care task" do
    task = plant_care_tasks(:beta_plant_watering)
    delete plant_plant_care_task_path(task.plant, task)
    assert_response :not_found
  end

  test "cannot complete another household's care task" do
    task = plant_care_tasks(:beta_plant_watering)
    post complete_plant_plant_care_task_path(task.plant, task)
    assert_response :not_found
  end
end

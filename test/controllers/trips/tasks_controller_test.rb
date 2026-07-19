require "test_helper"

class Trips::TasksControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create responds with a turbo stream" do
    trip = trips(:alpha_trip)
    assert_difference -> { trip.tasks.count }, 1 do
      post trip_tasks_path(trip), params: { task: { title: "Réserver" } }, as: :turbo_stream
    end
    assert_response :success
  end

  test "create with a blank title flashes an alert" do
    trip = trips(:alpha_trip)
    assert_no_difference -> { trip.tasks.count } do
      post trip_tasks_path(trip), params: { task: { title: "" } }
    end
    assert_redirected_to trip
  end

  test "gets the edit form" do
    trip = trips(:alpha_trip)
    task = trip.tasks.create!(household: households(:alpha), title: "T")
    get edit_trip_task_path(trip, task)
    assert_response :success
  end

  test "update renames a trip task" do
    trip = trips(:alpha_trip)
    task = trip.tasks.create!(household: households(:alpha), title: "T")
    patch trip_task_path(trip, task), params: { task: { title: "Nouveau titre" } }
    assert_redirected_to trip
    assert_equal "Nouveau titre", task.reload.title
  end

  test "toggle marks a trip task as done and responds with a turbo stream" do
    trip = trips(:alpha_trip)
    task = trip.tasks.create!(household: households(:alpha), title: "T", done: false)
    patch toggle_trip_task_path(trip, task), as: :turbo_stream
    assert_response :success
    assert task.reload.done
  end

  test "destroy responds with a turbo stream" do
    trip = trips(:alpha_trip)
    task = trip.tasks.create!(household: households(:alpha), title: "T")
    delete trip_task_path(trip, task), as: :turbo_stream
    assert_response :success
    assert_not Task.exists?(task.id)
  end

  test "cannot toggle a task from another household's trip" do
    trip = trips(:beta_trip)
    task = trip.tasks.create!(household: households(:beta), title: "T")
    patch toggle_trip_task_path(trip, task)
    assert_response :not_found
  end
end

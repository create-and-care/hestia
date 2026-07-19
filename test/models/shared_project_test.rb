require "test_helper"

class SharedProjectTest < ActiveSupport::TestCase
  test "requires a name" do
    project = households(:alpha).shared_projects.build
    assert_not project.valid?
    project.name = "Voyage"
    assert project.valid?
  end

  test "ordered scope orders by name" do
    b = households(:alpha).shared_projects.create!(name: "Zzz")
    a = households(:alpha).shared_projects.create!(name: "Aaa")

    ordered = households(:alpha).shared_projects.ordered
    assert_operator ordered.index(a), :<, ordered.index(b)
  end

  test "total_spent sums the shared expenses" do
    project = shared_projects(:alpha_trip)
    assert_equal 150, project.total_spent
  end

  test "destroying a project destroys its participants and expenses" do
    project = shared_projects(:alpha_trip)
    assert_difference [ "SharedProjectParticipant.count", "SharedExpense.count" ], -2 do
      project.destroy
    end
  end

  test "is scoped to its household" do
    assert_not_includes households(:alpha).shared_projects, shared_projects(:beta_project)
  end

  test "trip is optional" do
    project = households(:alpha).shared_projects.new(name: "Sans voyage")
    assert project.valid?
  end

  test "rejects a trip from another household" do
    project = households(:alpha).shared_projects.new(name: "Voyage", trip: trips(:beta_trip))
    assert_not project.valid?
    assert_includes project.errors[:trip], "is invalid"
  end
end

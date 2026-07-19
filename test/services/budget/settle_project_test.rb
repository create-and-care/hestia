require "test_helper"

module Budget
  class SettleProjectTest < ActiveSupport::TestCase
    test "splits the total equally and computes each balance" do
      balances = Budget::SettleProject.call(project: shared_projects(:alpha_trip))
      by_name = balances.index_by { |balance| balance.participant.name }
      # total 150, share 75; Alice paid 100 (+25), Bob paid 50 (-25)
      assert_equal 25, by_name["Alice"].amount
      assert_equal(-25, by_name["Bob"].amount)
    end

    test "returns no balances without participants" do
      project = households(:alpha).shared_projects.create!(name: "Vide")
      assert_empty Budget::SettleProject.call(project: project)
    end

    test "transfers suggests a minimal set of payments settling the balances" do
      transfers = Budget::SettleProject.transfers(project: shared_projects(:alpha_trip))
      assert_equal 1, transfers.size
      assert_equal "Bob", transfers.first.from.name
      assert_equal "Alice", transfers.first.to.name
      assert_equal 25, transfers.first.amount
    end

    test "transfers is empty when everyone is already settled" do
      project = households(:alpha).shared_projects.create!(name: "Équilibré")
      alice = project.shared_project_participants.create!(name: "Alice")
      bob = project.shared_project_participants.create!(name: "Bob")
      project.shared_expenses.create!(amount: 50, shared_project_participant: alice)
      project.shared_expenses.create!(amount: 50, shared_project_participant: bob)

      assert_empty Budget::SettleProject.transfers(project: project)
    end

    test "transfers needs at most participants.size - 1 payments for a 3-way split" do
      project = households(:alpha).shared_projects.create!(name: "Colocs")
      alice = project.shared_project_participants.create!(name: "Alice")
      bob = project.shared_project_participants.create!(name: "Bob")
      project.shared_project_participants.create!(name: "Chris")
      project.shared_expenses.create!(amount: 90, shared_project_participant: alice)
      project.shared_expenses.create!(amount: 30, shared_project_participant: bob)

      transfers = Budget::SettleProject.transfers(project: project)
      assert_operator transfers.size, :<=, 2
      assert_equal 50, transfers.sum(&:amount)
      assert_equal "Alice", transfers.map { |transfer| transfer.to.name }.uniq.sole
    end
  end
end

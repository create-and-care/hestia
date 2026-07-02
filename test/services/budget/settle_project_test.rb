require "test_helper"

module Budget
  class SettleProjectTest < ActiveSupport::TestCase
    test "splits the total equally and computes each balance" do
      balances = Budget::SettleProject.call(project: shared_projects(:alpha_trip))
      by_name = balances.index_by { |balance| balance.participant.name }
      # total 150, part 75 ; Alice a payé 100 (+25), Bob a payé 50 (-25)
      assert_equal 25, by_name["Alice"].amount
      assert_equal(-25, by_name["Bob"].amount)
    end

    test "returns no balances without participants" do
      project = households(:alpha).shared_projects.create!(name: "Vide")
      assert_empty Budget::SettleProject.call(project: project)
    end
  end
end

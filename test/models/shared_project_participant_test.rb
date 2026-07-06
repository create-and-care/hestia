require "test_helper"

class SharedProjectParticipantTest < ActiveSupport::TestCase
  test "requires a name" do
    participant = shared_projects(:alpha_trip).shared_project_participants.build
    assert_not participant.valid?
    participant.name = "Chris"
    assert participant.valid?
  end

  test "destroying a participant nullifies its expenses rather than destroying them" do
    participant = shared_project_participants(:trip_alice)
    expense = shared_expenses(:exp_one)
    assert_equal participant, expense.shared_project_participant

    assert_no_difference -> { SharedExpense.count } do
      participant.destroy
    end
    assert_nil expense.reload.shared_project_participant_id
  end
end

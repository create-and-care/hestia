require "test_helper"

class SavingsEnvelopesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as(users(:one)) }

  test "create requires authentication" do
    sign_out
    post savings_envelopes_path, params: { savings_envelope: { name: "Travaux", recurring_deposit: 100 } }
    assert_redirected_to new_session_path
  end

  test "create adds an envelope to the household" do
    assert_difference -> { households(:alpha).savings_envelopes.count }, 1 do
      post savings_envelopes_path, params: { savings_envelope: { name: "Travaux", recurring_deposit: 100 } }
    end
    assert_redirected_to budget_path
  end

  test "create with a blank name does not persist and flashes an error" do
    assert_no_difference -> { SavingsEnvelope.count } do
      post savings_envelopes_path, params: { savings_envelope: { name: "", recurring_deposit: 100 } }
    end
    assert_redirected_to budget_path
    assert_not_nil flash[:alert]
  end

  test "edit" do
    get edit_savings_envelope_path(savings_envelopes(:alpha_vacation))
    assert_response :success
  end

  test "cannot edit another household's envelope" do
    get edit_savings_envelope_path(savings_envelopes(:beta_env))
    assert_response :not_found
  end

  test "update" do
    envelope = savings_envelopes(:alpha_vacation)
    patch savings_envelope_path(envelope), params: { savings_envelope: { recurring_deposit: 250 } }
    assert_redirected_to budget_path
    assert_equal 250, envelope.reload.recurring_deposit
  end

  test "update with a blank name re-renders the edit form" do
    envelope = savings_envelopes(:alpha_vacation)
    patch savings_envelope_path(envelope), params: { savings_envelope: { name: "" } }
    assert_response :unprocessable_entity
    assert_equal "Vacances", envelope.reload.name
  end

  test "cannot update another household's envelope" do
    patch savings_envelope_path(savings_envelopes(:beta_env)), params: { savings_envelope: { name: "X" } }
    assert_response :not_found
  end

  test "destroy" do
    envelope = savings_envelopes(:alpha_vacation)
    delete savings_envelope_path(envelope)
    assert_redirected_to budget_path
    assert_not SavingsEnvelope.exists?(envelope.id)
  end

  test "cannot destroy another household's envelope" do
    delete savings_envelope_path(savings_envelopes(:beta_env))
    assert_response :not_found
  end
end

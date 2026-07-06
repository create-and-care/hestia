require "test_helper"

class SavingsEnvelopeTest < ActiveSupport::TestCase
  test "requires a name" do
    envelope = households(:alpha).savings_envelopes.build(recurring_deposit: 100)
    assert_not envelope.valid?
    envelope.name = "Vacances"
    assert envelope.valid?
  end

  test "ordered scope orders by name" do
    b = households(:alpha).savings_envelopes.create!(name: "Zzz")
    a = households(:alpha).savings_envelopes.create!(name: "Aaa")

    ordered = households(:alpha).savings_envelopes.ordered
    assert_operator ordered.index(a), :<, ordered.index(b)
  end

  test "is scoped to its household" do
    assert_not_includes households(:alpha).savings_envelopes, savings_envelopes(:beta_env)
  end
end

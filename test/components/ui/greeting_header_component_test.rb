require "test_helper"

class Ui::GreetingHeaderComponentTest < ViewComponent::TestCase
  test "renders the greeting and name as an h1 in the handwritten font" do
    render_inline(Ui::GreetingHeaderComponent.new(name: "Camille", greeting: "Bonjour"))

    assert_selector "h1.greeting", text: "Bonjour Camille"
  end

  test "renders the lead line when given" do
    render_inline(Ui::GreetingHeaderComponent.new(name: "Camille", greeting: "Bonjour", lead: "3 tâches vous attendent"))

    assert_selector "p", text: "3 tâches vous attendent"
  end

  test "omits the lead line when not given" do
    render_inline(Ui::GreetingHeaderComponent.new(name: "Camille", greeting: "Bonjour"))

    refute_selector "p"
  end

  test "derives a default greeting from the hour when none is given" do
    render_inline(Ui::GreetingHeaderComponent.new(name: "Camille", hour: 7))
    assert_selector "h1", text: "Good morning Camille"

    render_inline(Ui::GreetingHeaderComponent.new(name: "Camille", hour: 12))
    assert_selector "h1", text: "Enjoy your meal Camille"

    render_inline(Ui::GreetingHeaderComponent.new(name: "Camille", hour: 2))
    assert_selector "h1", text: "Good night Camille"

    render_inline(Ui::GreetingHeaderComponent.new(name: "Camille", hour: 23))
    assert_selector "h1", text: "Good evening Camille"
  end
end

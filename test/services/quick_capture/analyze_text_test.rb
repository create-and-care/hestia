require "test_helper"

module QuickCapture
  class AnalyzeTextTest < ActiveSupport::TestCase
    test "returns :task when the text contains a numeric date" do
      assert_equal :task, AnalyzeText.call(household: households(:alpha), text: "Rendez-vous chez le dentiste le 12/09")
    end

    test "returns :task when the text mentions a day of the week" do
      assert_equal :task, AnalyzeText.call(household: households(:alpha), text: "Appeler lundi pour le rendez-vous")
    end

    test "returns :shopping when the text mentions a product already in the household's catalog" do
      assert_equal :shopping, AnalyzeText.call(household: households(:alpha), text: "Il faut acheter du lait")
    end

    test "returns :note when nothing matches" do
      assert_equal :note, AnalyzeText.call(household: households(:alpha), text: "Idée de cadeau pour Léa")
    end

    test "a date match takes priority over a product match" do
      assert_equal :task, AnalyzeText.call(household: households(:alpha), text: "Acheter du lait lundi")
    end

    test "a product from another household is not matched" do
      assert_equal :note, AnalyzeText.call(household: households(:beta), text: "Il faut acheter du lait")
    end
  end
end

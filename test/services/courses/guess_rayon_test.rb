require "test_helper"

module Courses
  class GuessRayonTest < ActiveSupport::TestCase
    test "matches fruits and vegetables" do
      assert_equal "fruits_legumes", Courses::GuessRayon.call("2 tomates")
    end

    test "matches fresh/meat/fish items" do
      assert_equal "frais", Courses::GuessRayon.call("1 blanc de poulet")
      assert_equal "frais", Courses::GuessRayon.call("200 g de saumon")
    end

    test "matches pantry staples" do
      assert_equal "epicerie", Courses::GuessRayon.call("250 g de farine")
    end

    test "matches drinks" do
      assert_equal "boissons", Courses::GuessRayon.call("1 L de jus d'orange")
    end

    test "falls back to autre when nothing matches" do
      assert_equal "autre", Courses::GuessRayon.call("Objet divers")
    end

    test "is case-insensitive" do
      assert_equal "fruits_legumes", Courses::GuessRayon.call("TOMATES")
    end
  end
end

require "test_helper"

class RecipeStepTest < ActiveSupport::TestCase
  test "requires content" do
    step = recipes(:alpha_pancakes).recipe_steps.build
    assert_not step.valid?
    step.content = "Mélanger"
    assert step.valid?
  end

  test "belongs to a recipe" do
    step = RecipeStep.new(content: "Mélanger")
    assert_not step.valid?
    assert_includes step.errors[:recipe], "must exist"
  end

  test "is ordered by position on the recipe" do
    assert_equal [ recipe_steps(:pancakes_step_1), recipe_steps(:pancakes_step_2) ],
                 recipes(:alpha_pancakes).recipe_steps.to_a
  end
end

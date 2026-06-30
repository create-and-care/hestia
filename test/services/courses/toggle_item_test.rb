require "test_helper"

module Courses
  class ToggleItemTest < ActiveSupport::TestCase
    test "flips the checked state both ways" do
      item = shopping_list_items(:alpha_apples)
      assert_not item.checked

      Courses::ToggleItem.call(item: item)
      assert item.reload.checked

      Courses::ToggleItem.call(item: item)
      assert_not item.reload.checked
    end
  end
end

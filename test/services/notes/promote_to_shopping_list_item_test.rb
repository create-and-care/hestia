require "test_helper"

module Notes
  class PromoteToShoppingListItemTest < ActiveSupport::TestCase
    test "adds an item to the household's general shopping list from the note's title" do
      note = notes(:alpha_idea)
      shopping_list = households(:alpha).shopping_lists.general.first

      item = Notes::PromoteToShoppingListItem.call(note: note)

      assert_equal shopping_list, item.shopping_list
      assert_equal note.title, item.name
    end

    test "reuses an existing catalog product named inside the note's title instead of creating a duplicate" do
      note = households(:alpha).notes.create!(title: "Il faut acheter du lait")
      existing_product = products(:alpha_milk)
      item = nil

      assert_no_difference -> { Product.count } do
        item = Notes::PromoteToShoppingListItem.call(note: note)
      end

      assert_equal existing_product, item.product
      assert_equal existing_product.name, item.name
    end
  end
end

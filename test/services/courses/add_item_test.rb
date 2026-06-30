require "test_helper"

module Courses
  class AddItemTest < ActiveSupport::TestCase
    setup { @list = shopping_lists(:alpha_groceries) }

    test "creates an item at the next position" do
      item = Courses::AddItem.call(shopping_list: @list, name: "Beurre", rayon: "frais")
      assert_equal "Beurre", item.name
      assert_equal "frais", item.rayon
      assert_equal 2, item.position # fixtures occupy 0 and 1
    end

    test "adds an unknown product to the household catalogue" do
      assert_difference -> { households(:alpha).products.count }, 1 do
        Courses::AddItem.call(shopping_list: @list, name: "Yaourt", rayon: "frais")
      end
    end

    test "reuses an existing catalogue product and its rayon" do
      existing = products(:alpha_milk)
      assert_no_difference -> { households(:alpha).products.count } do
        item = Courses::AddItem.call(shopping_list: @list, name: "lait")
        assert_equal existing, item.product
        assert_equal "frais", item.rayon
      end
    end

    test "defaults the rayon to autre" do
      item = Courses::AddItem.call(shopping_list: @list, name: "Objet divers")
      assert_equal "autre", item.rayon
    end
  end
end

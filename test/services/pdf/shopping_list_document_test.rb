require "test_helper"

module Pdf
  class ShoppingListDocumentTest < ActiveSupport::TestCase
    test "renders a PDF grouping items by rayon in store-aisle order" do
      list = shopping_lists(:alpha_groceries)
      list.items.create!(name: "Eau", rayon: "boissons")
      list.items.create!(name: "Divers", rayon: "autre")
      list.items.create!(name: "Tomate", rayon: "fruits_legumes")

      pdf = Pdf::ShoppingListDocument.new(list).render
      assert pdf.start_with?("%PDF")
    end

    test "does not drop items with no rayon set" do
      list = shopping_lists(:alpha_groceries)
      list.items.create!(name: "Mystère", rayon: nil)

      assert_nothing_raised { Pdf::ShoppingListDocument.new(list).render }
    end
  end
end

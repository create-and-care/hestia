module Notes
  # Promotes a note into a shopping list item (interconnection Notes → Courses).
  class PromoteToShoppingListItem
    def self.call(note:)
      shopping_list = note.household.shopping_lists.general.order(:created_at).first ||
        note.household.shopping_lists.create!(name: I18n.t("shopping_lists.default_list_name"))

      # If the note's title names a product already in the catalog (the same
      # match Quick Capture used to suggest this promotion in the first
      # place), add that product itself rather than the whole sentence —
      # otherwise Courses::AddItem's own exact-name lookup misses it and
      # spawns a near-duplicate catalog entry named after the full phrase.
      product = Product.matching(household: note.household, text: note.title)
      Courses::AddItem.call(shopping_list: shopping_list, name: product&.name || note.title, product: product)
    end
  end
end

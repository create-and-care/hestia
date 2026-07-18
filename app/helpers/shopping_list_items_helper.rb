module ShoppingListItemsHelper
  def rayon_label(rayon)
    t("shopping_list_items.rayons.#{rayon}", default: t("shopping_list_items.rayons.autre"))
  end

  def rayon_select_options
    ShoppingListItem::RAYONS.map { |rayon| [ rayon_label(rayon), rayon ] }
  end

  def catalog_products
    Current.household.products.order(:name)
  end
end

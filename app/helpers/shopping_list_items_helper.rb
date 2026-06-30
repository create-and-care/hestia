module ShoppingListItemsHelper
  RAYON_LABELS = {
    "fruits_legumes" => "Fruits & légumes",
    "frais" => "Frais",
    "surgeles" => "Surgelés",
    "epicerie" => "Épicerie",
    "boissons" => "Boissons",
    "hygiene" => "Hygiène",
    "maison" => "Maison",
    "autre" => "Autre"
  }.freeze

  def rayon_label(rayon)
    RAYON_LABELS.fetch(rayon, RAYON_LABELS.fetch("autre"))
  end

  def rayon_select_options
    ShoppingListItem::RAYONS.map { |rayon| [ rayon_label(rayon), rayon ] }
  end
end

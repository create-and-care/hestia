class ProductsController < ApplicationController
  # Catalogue de produits du foyer, alimenté automatiquement au fil des ajouts (CDC §9.1).
  def index
    @products = Current.household.products.order(:rayon, :name)
  end
end

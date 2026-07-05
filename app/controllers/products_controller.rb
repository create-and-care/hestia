class ProductsController < ApplicationController
  # Catalogue de produits du foyer, alimenté automatiquement au fil des ajouts (CDC §9.1).
  def index
    @products = Current.household.products.order(:rayon, :name)
  end

  # Recherche par code-barres (Courses/Frigo, CDC §9.1, §9.4, §16) : d'abord dans le
  # catalogue du foyer (scan déjà connu), puis auprès d'Open Food Facts.
  def lookup
    barcode = params[:barcode].to_s
    return head(:not_found) if barcode.blank?

    known = Current.household.products.find_by(barcode: barcode)

    result = if known
      { name: known.name, brand: known.brand, rayon: known.rayon }
    else
      OpenFoodFacts::LookupProduct.call(barcode: barcode)
    end

    if result
      render json: result
    else
      head :not_found
    end
  end
end

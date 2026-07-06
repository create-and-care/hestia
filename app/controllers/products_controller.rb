class ProductsController < ApplicationController
  # Household product catalog, automatically populated as items are added (Spec §9.1).
  def index
    @products = Current.household.products.order(:rayon, :name)
  end

  # Barcode lookup (Shopping/Fridge, Spec §9.1, §9.4, §16): first in the
  # household catalog (already-known scan), then via Open Food Facts.
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

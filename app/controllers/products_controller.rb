class ProductsController < ApplicationController
  # Household product catalog, automatically populated as items are added (Spec §9.1).
  def index
    @query = params[:q].to_s.strip
    products = Current.household.products.order(:rayon, :name)
    products = products.where("name ILIKE :q OR brand ILIKE :q", q: "%#{@query}%") if @query.present?
    @products = products
    @shopping_lists = Current.household.shopping_lists.general.order(:name)
  end

  # Adds a catalog product to one of the household's shopping lists, so the
  # catalog page is more than a read-only reference (Spec §9.1).
  def add_to_list
    product = Current.household.products.find(params[:id])
    list = Current.household.shopping_lists.general.find(params[:shopping_list_id])
    Courses::AddItem.call(shopping_list: list, name: product.name, rayon: product.rayon, product: product)
    redirect_to products_path, notice: t(".added", name: product.name, list: list.name)
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

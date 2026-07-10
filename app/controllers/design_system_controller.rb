class DesignSystemController < ApplicationController
  allow_unauthenticated_access
  allow_without_household

  before_action :set_categories

  def index
  end

  def colors
  end

  def typography
  end

  def icons
    @query = params[:q].to_s
    @icon_names = Dir.children(Rails.root.join("app/assets/icons/lucide")).map { |f| f.sub(/\.svg\z/, "") }.sort
  end

  def component
    @entry = DesignSystemRegistry.find(params[:id])
    raise ActionController::RoutingError, "Unknown design system component: #{params[:id]}" unless @entry
  end

  private

  def set_categories
    @categories = DesignSystemRegistry.grouped_by_category
  end
end

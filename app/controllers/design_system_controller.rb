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

  ILLUSTRATION_SLOTS = %i[courses fridge gifts onboarding].freeze

  def illustrations
    illustrations_dir = Rails.root.join("app/assets/images/illustrations")
    @illustration_slots = ILLUSTRATION_SLOTS.index_with do |slug|
      %w[svg png].map { |ext| "illustrations/#{slug}.#{ext}" }
        .find { |rel_path| illustrations_dir.join(File.basename(rel_path)).exist? }
    end
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

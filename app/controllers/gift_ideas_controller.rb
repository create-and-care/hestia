class GiftIdeasController < ApplicationController
  before_action :set_list
  before_action :set_idea, only: %i[update destroy]

  def create
    @list.gift_ideas.create(idea_params)
    redirect_to @list
  end

  def update
    @idea.update(idea_params)
    redirect_to @list
  end

  def destroy
    @idea.destroy
    redirect_to @list
  end

  private
    def set_list
      @list = Current.household.gift_lists.find(params[:gift_list_id])
      raise ActiveRecord::RecordNotFound unless @list.visible_to?(Current.user)
    end

    def set_idea
      @idea = @list.gift_ideas.find(params[:id])
    end

    def idea_params
      params.require(:gift_idea).permit(:name, :price, :url, :comment, :status, :photo)
    end
end

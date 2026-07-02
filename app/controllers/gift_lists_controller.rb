class GiftListsController < ApplicationController
  before_action :set_list, only: %i[show destroy]

  def index
    @receive_lists = Current.household.gift_lists.where(perspective: "receive").includes(:gift_list_share).ordered
    @give_lists = Current.household.gift_lists.where(perspective: "give").includes(:contact).ordered
    @list = Current.household.gift_lists.new
  end

  def show
    @idea = @list.gift_ideas.new
  end

  def create
    @list = Current.household.gift_lists.new(list_params)
    @list.contact = scoped_contact
    if @list.save
      redirect_to @list
    else
      redirect_to gift_lists_path, alert: @list.errors.full_messages.to_sentence
    end
  end

  def destroy
    @list.destroy
    redirect_to gift_lists_path, notice: "Liste supprimée."
  end

  private
    def set_list
      @list = Current.household.gift_lists.find(params[:id])
    end

    def scoped_contact
      id = params.dig(:gift_list, :contact_id)
      Current.household.contacts.find_by(id: id) if id.present?
    end

    def list_params
      params.require(:gift_list).permit(:name, :perspective)
    end
end

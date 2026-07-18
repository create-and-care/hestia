class GiftListsController < ApplicationController
  before_action :set_list, only: %i[show edit update destroy]
  before_action :require_visible!, only: %i[show edit update destroy]
  before_action :require_creator!, only: %i[edit update destroy]

  def index
    visible_lists = Current.household.gift_lists.includes(:gift_list_share, :contact).ordered
      .select { |list| list.visible_to?(Current.user) }
    @receive_lists = visible_lists.select { |l| l.perspective == "receive" }
    @give_lists = visible_lists.select { |l| l.perspective == "give" }
    @list = Current.household.gift_lists.new
  end

  def show
    @ideas = @list.gift_ideas.ordered.includes(photo_attachment: :blob)
    @idea = @list.gift_ideas.new
  end

  def create
    @list = Current.household.gift_lists.new(list_params)
    @list.created_by = Current.user
    @list.contact = scoped_contact
    @list.visible_to_ids = visible_to_ids_param
    if @list.save
      redirect_to @list
    else
      redirect_to gift_lists_path, alert: @list.errors.full_messages.to_sentence
    end
  end

  def edit
    @household_members = Current.household.users.where.not(id: @list.created_by_id).order(:name)
  end

  def update
    @list.contact = scoped_contact
    @list.visible_to_ids = visible_to_ids_param
    if @list.update(list_params)
      redirect_to @list, notice: t(".updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @list.destroy
    redirect_to gift_lists_path, notice: t(".deleted")
  end

  private
    def set_list
      @list = Current.household.gift_lists.find(params[:id])
    end

    def require_visible!
      raise ActiveRecord::RecordNotFound unless @list.visible_to?(Current.user)
    end

    # Renaming/perspective/visibility changes are limited to whoever created
    # the list — anyone else with access can still view and add ideas.
    def require_creator!
      return if @list.created_by_id.nil? || @list.created_by_id == Current.user.id
      redirect_to @list, alert: t("gift_lists.not_creator")
    end

    def scoped_contact
      return nil if list_params[:perspective] == "receive"
      id = params.dig(:gift_list, :contact_id)
      Current.household.contacts.find_by(id: id) if id.present?
    end

    def list_params
      params.require(:gift_list).permit(:name, :perspective, :theme, :restricted)
    end

    def visible_to_ids_param
      Current.household.users.where(id: Array(params.dig(:gift_list, :visible_to_ids))).ids
    end
end

class ContactsController < ApplicationController
  before_action :set_contact, only: %i[edit update destroy]

  def index
    @tags = Current.household.contact_tags.order(:name)
    @tag = @tags.find_by(id: params[:tag_id]) if params[:tag_id].present?

    contacts = Current.household.contacts.includes(:contact_tags)
    contacts = contacts.joins(:contact_taggings).where(contact_taggings: { contact_tag_id: @tag.id }) if @tag
    @contacts = contacts.to_a.sort_by { |contact| contact.days_until_birthday || 100_000 }
  end

  def new
    @contact = Current.household.contacts.new
  end

  def create
    @contact = Current.household.contacts.new(contact_params)
    @contact.contact_tag_ids = scoped_tag_ids

    if @contact.save
      redirect_to contacts_path, notice: t(".created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @contact.assign_attributes(contact_params)
    @contact.contact_tag_ids = scoped_tag_ids

    if @contact.save
      redirect_to contacts_path, notice: t(".updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @contact.destroy
    redirect_to contacts_path, notice: t(".deleted")
  end

  private
    def set_contact
      @contact = Current.household.contacts.find(params[:id])
    end

    def contact_params
      params.require(:contact).permit(:name, :born_on, :year_known)
    end

    def scoped_tag_ids
      Current.household.contact_tags.where(id: Array(params[:contact_tag_ids])).ids
    end
end

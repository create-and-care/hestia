class ContactsController < ApplicationController
  before_action :set_contact, only: %i[edit update destroy]

  def index
    @tags = Current.household.contact_tags.order(:name)
    @tag = @tags.find_by(id: params[:tag_id]) if params[:tag_id].present?

    contacts = Current.household.contacts.includes(:contact_tags, :gift_lists)
    contacts = contacts.joins(:contact_taggings).where(contact_taggings: { contact_tag_id: @tag.id }) if @tag
    @contacts = contacts.to_a.sort_by { |contact| contact.days_until_birthday || 100_000 }
  end

  # Monthly grid view of birthdays (Spec: "liste + vue calendrier"), alongside the
  # proximity-sorted list — mirrors the Calendar module's own month-grid pattern.
  def calendar
    @month = parse_month
    grid_start = @month.beginning_of_month.beginning_of_week
    grid_end = @month.end_of_month.end_of_week
    @dates = (grid_start..grid_end)
    @by_day = birthdays_by_day(grid_start, grid_end)
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

    def birthdays_by_day(from, to)
      Current.household.contacts.where.not(born_on: nil).each_with_object(Hash.new { |hash, key| hash[key] = [] }) do |contact, by_day|
        contact.birthdays_between(from.to_date, to.to_date).each { |date| by_day[date] << contact }
      end
    end

    def parse_month
      Date.parse("#{params[:month]}-01")
    rescue ArgumentError, TypeError
      Date.current.beginning_of_month
    end
end

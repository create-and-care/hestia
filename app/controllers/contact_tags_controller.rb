class ContactTagsController < ApplicationController
  def create
    tag = Current.household.contact_tags.new(contact_tag_params)
    if tag.save
      redirect_to contacts_path, notice: t(".created")
    else
      redirect_to contacts_path, alert: tag.errors.full_messages.to_sentence
    end
  end

  def destroy
    Current.household.contact_tags.find(params[:id]).destroy
    redirect_to contacts_path, notice: t(".deleted")
  end

  private
    def contact_tag_params
      params.require(:contact_tag).permit(:name, :emoji)
    end
end

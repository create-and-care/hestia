class ContactTagsController < ApplicationController
  def create
    Current.household.contact_tags.create(contact_tag_params)
    redirect_to contacts_path
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

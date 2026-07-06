module Api
  module V1
    class ContactsController < BaseController
      def index
        contacts = Current.household.contacts
        # Sort by upcoming birthday in Ruby (not a DB column), then reapply
        # that order to a relation via `in_order_of` so it stays chainable with `paginate`.
        ordered_ids = contacts.to_a.sort_by { |contact| contact.days_until_birthday || Float::INFINITY }.map(&:id)
        render json: paginate(contacts.in_order_of(:id, ordered_ids)).map { |contact| serialize(contact) }
      end

      def show
        render json: serialize(find_contact)
      end

      private
        def find_contact
          Current.household.contacts.find(params[:id])
        end

        def serialize(contact)
          contact.as_json(only: %i[id name born_on year_known]).merge(days_until_birthday: contact.days_until_birthday)
        end
    end
  end
end

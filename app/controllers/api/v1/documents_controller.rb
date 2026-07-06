module Api
  module V1
    class DocumentsController < BaseController
      # Index only: file blobs/URLs are intentionally not serialized here (Active
      # Storage attachment, not a plain column) — keep the payload to metadata.
      def index
        render json: paginate(Current.household.documents.ordered).map { |document| serialize(document) }
      end

      private
        def serialize(document)
          document.as_json(only: %i[id name document_folder_id created_at])
        end
    end
  end
end

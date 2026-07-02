class DocumentsController < ApplicationController
  before_action :set_document, only: %i[show destroy]

  def index
    @query = params[:q].to_s.strip
    @folder = Current.household.document_folders.find_by(id: params[:folder_id]) if params[:folder_id].present?
    @folders = Current.household.document_folders.ordered

    documents = Current.household.documents.ordered.with_attached_file
    documents = documents.where(document_folder_id: @folder.id) if @folder
    documents = documents.where("name ILIKE ?", "%#{@query}%") if @query.present?
    @documents = documents
    @document = Current.household.documents.new
  end

  def show
    redirect_to rails_blob_path(@document.file, disposition: "inline")
  end

  def create
    @document = Current.household.documents.new(document_params)
    if @document.save
      redirect_to documents_path, notice: "Document ajouté."
    else
      redirect_to documents_path, alert: @document.errors.full_messages.to_sentence
    end
  end

  def destroy
    @document.destroy
    redirect_to documents_path, notice: "Document supprimé."
  end

  private
    def set_document
      @document = Current.household.documents.find(params[:id])
    end

    def document_params
      permitted = params.require(:document).permit(:name, :document_folder_id, :file)
      unless permitted[:document_folder_id].blank? || Current.household.document_folders.exists?(id: permitted[:document_folder_id])
        permitted[:document_folder_id] = nil
      end
      permitted
    end
end

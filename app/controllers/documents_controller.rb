class DocumentsController < ApplicationController
  include CollectionViewMode

  before_action :set_document, only: %i[show edit update destroy preview]
  layout false, only: :preview

  DOCUMENTABLE_SCOPES = {
    "Vehicle" => :vehicles,
    "Pet" => :pets,
    "ServiceProvider" => :service_providers,
    "BudgetCategory" => :budget_categories
  }.freeze

  def index
    @query = params[:q].to_s.strip
    @folder = Current.household.document_folders.find_by(id: params[:folder_id]) if params[:folder_id].present?
    @folders = Current.household.document_folders.ordered

    # Each row shows its folder and what it is attached to, alongside the file
    # itself (PERF-06). :documentable is polymorphic, so it is preloaded rather
    # than joined.
    documents = Current.household.documents.ordered.includes(:document_folder, :documentable)
    documents = documents.where(document_folder_id: @folder.id) if @folder
    documents = documents.where("name ILIKE ?", "%#{@query}%") if @query.present?
    @documents = documents
    @document = Current.household.documents.new
    @view_mode = collection_view_mode(:documents)
    @documentable_options = documentable_options
  end

  def show
    redirect_to rails_blob_path(@document.file, disposition: "inline")
  end

  def preview
  end

  def edit
    @documentable_options = documentable_options
  end

  def create
    @document = Current.household.documents.new(document_attributes)
    assign_documentable(@document)
    if @document.save
      redirect_to documents_path, notice: t(".created")
    else
      redirect_to documents_path, alert: @document.errors.full_messages.to_sentence
    end
  end

  def update
    @document.assign_attributes(document_attributes)
    assign_documentable(@document)
    if @document.save
      redirect_to documents_path, notice: t(".updated")
    else
      @documentable_options = documentable_options
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @document.destroy
    redirect_to documents_path, notice: t(".deleted")
  end

  private
    def set_document
      @document = Current.household.documents.find(params[:id])
    end

    def document_params
      permitted = params.require(:document).permit(:name, :document_folder_id, :file, :documentable_key)
      unless permitted[:document_folder_id].blank? || Current.household.document_folders.exists?(id: permitted[:document_folder_id])
        permitted[:document_folder_id] = nil
      end
      permitted
    end

    def document_attributes
      attributes = document_params.except(:documentable_key, :file)
      uploaded = document_params[:file]
      return attributes if uploaded.blank?

      if uploaded.content_type.to_s.start_with?("image/")
        attributes[:file] = {
          io: Documents::PhotoToPdf.call(uploaded),
          filename: "#{File.basename(uploaded.original_filename, ".*")}.pdf",
          content_type: "application/pdf"
        }
      else
        attributes[:file] = uploaded
      end
      attributes
    end

    def assign_documentable(document)
      type, id = document_params[:documentable_key].to_s.split("-", 2)
      scope_name = DOCUMENTABLE_SCOPES[type]
      document.documentable = scope_name ? Current.household.public_send(scope_name).find_by(id: id) : nil
    end

    def documentable_options
      [ [ t("documents.index.documentable_none"), "" ] ] +
        DOCUMENTABLE_SCOPES.flat_map do |type, scope_name|
          Current.household.public_send(scope_name).ordered.map do |record|
            [ "#{record.name} (#{t("documents.index.documentable_groups.#{type.underscore}")})", "#{type}-#{record.id}" ]
          end
        end
    end
end

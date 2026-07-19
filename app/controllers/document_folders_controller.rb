class DocumentFoldersController < ApplicationController
  before_action :set_folder, only: %i[edit update destroy]

  def create
    folder = Current.household.document_folders.create(folder_params)
    if folder.persisted?
      redirect_to documents_path, notice: t(".created")
    else
      redirect_to documents_path, alert: folder.errors.full_messages.to_sentence
    end
  end

  def edit
  end

  def update
    if @folder.update(folder_params)
      redirect_to documents_path, notice: t(".updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @folder.destroy
    redirect_to documents_path, notice: t(".deleted")
  end

  private
    def set_folder
      @folder = Current.household.document_folders.find(params[:id])
    end

    def folder_params
      params.require(:document_folder).permit(:name, :color)
    end
end

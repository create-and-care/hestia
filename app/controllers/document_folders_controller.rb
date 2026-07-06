class DocumentFoldersController < ApplicationController
  def create
    Current.household.document_folders.create(folder_params)
    redirect_to documents_path
  end

  def destroy
    Current.household.document_folders.find(params[:id]).destroy
    redirect_to documents_path, notice: t(".deleted")
  end

  private
    def folder_params
      params.require(:document_folder).permit(:name, :color)
    end
end

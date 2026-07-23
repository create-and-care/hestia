class NotesController < ApplicationController
  include CollectionViewMode

  before_action :set_note, only: %i[edit update destroy toggle_favorite toggle_archive promote_to_task]

  PER_PAGE = 20

  def index
    @query = params[:q].to_s.strip
    @archived = params[:archived].present?
    notes = Current.household.notes.general.ordered.includes(:recipe, :document)
    notes = @archived ? notes.archived : notes.active
    notes = notes.where("title ILIKE :q OR content ILIKE :q", q: "%#{@query}%") if @query.present?
    @view_mode = collection_view_mode(:notes)

    @total = notes.count
    @total_pages = [ (@total / PER_PAGE.to_f).ceil, 1 ].max
    @page = [ [ params[:page].to_i, 1 ].max, @total_pages ].min
    @notes = notes.offset((@page - 1) * PER_PAGE).limit(PER_PAGE)
    @note = Note.new
  end

  def create
    Current.household.notes.create!(note_params.merge(author: Current.user))
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to notes_path }
    end
  rescue ActiveRecord::RecordInvalid
    redirect_to notes_path, alert: t(".cannot_create")
  end

  def edit
    load_linkable_collections
  end

  def update
    if @note.update(note_params)
      redirect_to notes_path, notice: t(".updated")
    else
      load_linkable_collections
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @note.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@note) }
      format.html { redirect_to notes_path(preserved_filter_params) }
    end
  end

  def toggle_favorite
    @note.update!(favorite: !@note.favorite)
    redirect_to notes_path(preserved_filter_params)
  end

  def toggle_archive
    @note.update!(archived: !@note.archived)
    redirect_to notes_path(preserved_filter_params)
  end

  def promote_to_task
    Notes::PromoteToTask.call(note: @note)
    redirect_to notes_path(preserved_filter_params), notice: t(".promoted")
  end

  private
    def set_note
      @note = Current.household.notes.find(params[:id])
    end

    def note_params
      params.require(:note).permit(:title, :content, :color, :recipe_id, :document_id)
    end

    def preserved_filter_params
      { q: params[:q].presence, archived: params[:archived].presence }
    end

    def load_linkable_collections
      @recipes = Current.household.recipes.order(:title)
      @documents = Current.household.documents.order(:name)
    end
end

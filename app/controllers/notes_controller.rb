class NotesController < ApplicationController
  before_action :set_note, only: %i[edit update destroy toggle_favorite toggle_archive promote_to_task]

  def index
    @query = params[:q].to_s.strip
    @archived = params[:archived].present?
    notes = Current.household.notes.general.ordered
    notes = @archived ? notes.archived : notes.active
    notes = notes.where("title ILIKE :q OR content ILIKE :q", q: "%#{@query}%") if @query.present?
    @notes = notes
    @note = Note.new
  end

  def create
    Current.household.notes.create!(note_params.merge(author: Current.user))
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to notes_path }
    end
  rescue ActiveRecord::RecordInvalid
    redirect_to notes_path, alert: "Impossible de créer la note."
  end

  def edit
  end

  def update
    if @note.update(note_params)
      redirect_to notes_path, notice: "Note mise à jour."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @note.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@note) }
      format.html { redirect_to notes_path }
    end
  end

  def toggle_favorite
    @note.update!(favorite: !@note.favorite)
    redirect_to notes_path
  end

  def toggle_archive
    @note.update!(archived: !@note.archived)
    redirect_to notes_path
  end

  def promote_to_task
    Notes::PromoteToTask.call(note: @note)
    redirect_to notes_path, notice: "Note promue en tâche."
  end

  private
    def set_note
      @note = Current.household.notes.find(params[:id])
    end

    def note_params
      params.require(:note).permit(:title, :content)
    end
end

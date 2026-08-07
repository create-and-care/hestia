module TaskViewMode
  extend ActiveSupport::Concern

  MODES = %w[agenda board].freeze

  private
    # Agenda (grouped by when a task is due) vs board (grouped by category),
    # remembered across visits the way RecipeViewMode does — a purely cosmetic
    # preference, so session rather than a schema change.
    #
    # Agenda is the default: a household task list is read to answer "what needs
    # doing now", and a category is not a workflow state you move a task through.
    def task_view_mode
      mode = params[:view].presence || session[:task_view_mode] || "agenda"
      mode = "agenda" unless MODES.include?(mode)
      session[:task_view_mode] = mode
      mode
    end
end

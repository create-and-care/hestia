module Tasks
  # Toggles a task's done / to-do state.
  class ToggleTask
    def self.call(task:)
      task.update!(done: !task.done)
      task
    end
  end
end

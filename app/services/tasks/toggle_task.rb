module Tasks
  # Bascule l'état fait / à faire d'une tâche.
  class ToggleTask
    def self.call(task:)
      task.update!(done: !task.done)
      task
    end
  end
end

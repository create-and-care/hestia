module Notes
  # Promeut une note en tâche actionnable (interconnexion Notes → Tâches, CDC §10.1).
  class PromoteToTask
    def self.call(note:)
      Tasks::CreateTask.call(household: note.household, title: note.title, description: note.content)
    end
  end
end

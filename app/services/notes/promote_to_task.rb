module Notes
  # Promotes a note into an actionable task (interconnection Notes → Tasks, Spec §10.1).
  class PromoteToTask
    def self.call(note:)
      Tasks::CreateTask.call(household: note.household, title: note.title, description: note.content)
    end
  end
end

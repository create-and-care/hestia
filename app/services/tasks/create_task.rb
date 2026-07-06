module Tasks
  # Creates a task within the household. Application service invocable by the web, the API and Hest.AI.
  class CreateTask
    def self.call(household:, title:, description: nil, emoji: nil, due_on: nil, assignee: nil, task_category: nil)
      household.tasks.create!(
        title: title,
        description: description,
        emoji: emoji,
        due_on: due_on,
        assignee: assignee,
        task_category: task_category,
        position: (household.tasks.maximum(:position) || -1) + 1
      )
    end
  end
end

module ConversationsHelper
  def conversation_subject_label(subject)
    subject.try(:title) || subject.try(:name)
  end

  def conversation_subject_path(subject)
    case subject
    when Task then edit_task_path(subject)
    when ShoppingList then shopping_list_path(subject)
    when CalendarEvent then edit_calendar_event_path(subject)
    end
  end
end

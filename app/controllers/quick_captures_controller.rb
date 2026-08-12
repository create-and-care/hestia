class QuickCapturesController < ApplicationController
  # Always saved as a note first — see QuickCapture::AnalyzeText: a rule match
  # only ever adds a one-tap suggestion, it never redirects the write
  # elsewhere. An unfiled capture that silently went missing would be worse
  # than no capture box at all.
  def create
    @panel_id = params[:panel_id].presence || "quick_capture_panel"
    text = params.require(:quick_capture)[:text].to_s.strip

    if text.blank?
      @blank = true
    else
      @note = Current.household.notes.create!(title: text, author: Current.user)
      @suggestion = QuickCapture::AnalyzeText.call(household: Current.household, text: text)
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to notes_path }
    end
  end
end

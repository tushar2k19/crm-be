class NoteController < ApplicationController
  def notes
    conv_id = params[:conversation_id]
    all_notes = []
    Note.where(conversation_id: conv_id).each do |note|
      note = {
        id: note.id,
        content: note.note,
        addedBy: note.added_by,
        createdAt: note.created_at.in_time_zone('Mumbai').strftime("%Y/%m/%d %I:%M %p"),
      }
      all_notes << note
    end
    render json: {status: 'Success', message: 'Loaded all notes', data: all_notes}, status: :ok
  end

  def create
    conv_id = params[:conversation_id]
    note = params[:note]
    added_by = @current_user || "Admin"
    new_note = Note.create(conversation_id: conv_id, note: note, added_by: added_by)

    render json: {success: true, note: new_note} , status: :ok
  end
end

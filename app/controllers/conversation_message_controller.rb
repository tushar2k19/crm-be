class ConversationMessageController < ApplicationController
  before_action :authorize_access_request!, only: [:send_message]
  def messages
    conv_id = params[:conversation_id]
    all_messages =[]
    ConversationMessage.where(conversation_id: conv_id).each do |message|
      message = {
        id: message.id,
        content: message.message,
        sentAt: message.sent_at,
        senderName: message.sent_by || "Admin"
      }
      all_messages << message
    end
    render json: {success: true, messages: all_messages}

  end

  def send_message
    conv_id = params[:conversation_id]
    message = params[:message]
    conversation = Conversation.find(conv_id)
    phone_number = conversation.profile.phone.to_s
    msg = TwilioSms.send_text(phone_number, message)
    Rails.logger.info "twilio #{msg}"
    ConversationMessage.create(message: message, sent_at: Time.zone.now.in_time_zone('Mumbai').strftime("%Y/%m/%d %I:%M %p"),
                               sent_by: @current_user, conversation_id: conversation.id)
    conversation.update(last_message: message)
    conversation.save
    render json: {success: true, message: msg}
  end
end


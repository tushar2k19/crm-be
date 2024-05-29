class ConversationController < ApplicationController
  def conversations
    all_conversations = []
    Conversation.where.not(last_message: nil).each do |conversation|
      conv_details ={
        name: conversation.profile.name,
        id: conversation.id,
        last_message: conversation.last_message,
        sent_time: conversation.updated_at.in_time_zone('Mumbai')
      }
      all_conversations << conv_details
    end
    all_conversations.sort_by! { |conv| conv[:sent_time] }.reverse!
    all_conversations.each do |conv|
      conv[:sent_time] = conv[:sent_time].strftime("%m/%d/%Y %I:%M %p")
    end
    render json: {success: true, conversations: all_conversations}
  end


  def find_conversation
    name = params[:name].to_s.strip.downcase
    all_conversations = []
    profiles = Profile.where("LOWER(name) LIKE ?", "%#{name}%")

    profiles.each do |profile|
      conversation = Conversation.find_by(profile_id: profile.id)
      conv_obj = {
        name: profile.name,
        id: conversation.id,
        last_message: conversation.last_message,
        sent_time: conversation.last_conv_time
      }
      all_conversations << conv_obj;
    end
    render json: {success: true, conversation: all_conversations}
  end
end
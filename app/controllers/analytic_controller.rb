class AnalyticController < ApplicationController
  def index
    count1 = Profile.all.count
    count2 = Profile.where(created_at: (Time.zone.now - 7.days)..Time.zone.now).count
    count3 = ConversationMessage.where(created_at: Time.zone.now-7.days..Time.zone.now).pluck(:conversation_id).uniq.count

    render json: {success: true, total_count: count1, weekly_count: count2, weekly_conv_count: count3}
  end
end

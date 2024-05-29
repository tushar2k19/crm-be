class ProfileController < ApplicationController
  def create
    profile = Profile.create(profile_params)
    Conversation.create(profile_id: profile.id)
    render json: { success: true }, status: :ok
  end

  def delete_profile
    conversation = Conversation.find_by(profile_id: params[:id])
    ConversationMessage.where(conversation_id: conversation.id).delete_all if conversation.present?
    conversation.destroy if conversation.present?
    Profile.find(params[:id])&.destroy
    render json: { success: true }, status: :ok
  end

  def edit_profile
    Profile.find(params[:id]).update(profile_params)
    render json: { success: true }, status: :ok
  end

  def profiles
    limit = 5
    page = params[:page].to_i
    all_profiles = Profile.all.map do |profile|
      {
        id: profile.id,
        name: profile.name,
        email: profile.email,
        phone: profile.phone,
        created_at: profile.created_at,
      }
    end

    sorted_profiles = all_profiles.sort_by { |profile| profile[:created_at] }.reverse
    start_index = (page - 1) * limit
    end_index = page * limit - 1
    paginated_data = sorted_profiles[start_index..end_index]
    render json: { success: true, data: paginated_data, count: sorted_profiles.count }
  end

  def search
    limit = 5
    all_profiles = []
    page = params[:page].to_i
    name = params[:searchText].to_s.strip.downcase
    Profile.where("LOWER(name) LIKE ?", "%#{name}%").each do |profile|
      profile = {
        id: profile.id,
        name: profile.name,
        email: profile.email,
        phone: profile.phone,
        created_at: profile.created_at,
      }
      all_profiles << profile
    end

    sorted_profiles = all_profiles.sort_by {|profile| profile[:created_at] }.reverse
    start_index = (page - 1) * limit
    end_index = page * limit - 1
    paginated_data = sorted_profiles[start_index..end_index]
    render json: { success: true, data: paginated_data, count: sorted_profiles.count }
  end

  def filter
    start_date = Date.parse(params[:start]).to_time.utc
    end_date = Date.parse(params[:end]).to_time.utc
    limit = 5
    page = params[:page].to_i
    all_profiles = []
    Profile.where(created_at: start_date.beginning_of_day..end_date.end_of_day).each do |profile|
      profile = {
        id: profile.id,
        name: profile.name,
        email: profile.email,
        phone: profile.phone,
        created_at: profile.created_at,
      }
      all_profiles << profile
    end
    sorted_profiles = all_profiles.sort_by{|profile| profile[:created_at]}.reverse
    start_index = (page - 1) * limit
    end_index = page * limit - 1
    paginated_data = sorted_profiles[start_index..end_index]
    render json: { success: true, data: paginated_data, count: sorted_profiles.count }
  end

  private

  def profile_params
    params.permit(:name, :email, :phone)
  end
end

class ApplicationController < ActionController::API
  include JWTSessions::RailsAuthorization
  rescue_from JWTSessions::Errors::Unauthorized, with: :not_authorized

  private
  def current_user
    @current_user || User.find(payload['user_id'])  #comes from the JWT sessions (line 2)
  end
  def not_authorized
    render json: { error: "Not authorized" }, status: :unauthorized
  end

end

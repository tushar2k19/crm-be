class SigninController < ApplicationController
  before_action :authorize_access_request!, only: [:destroy]

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      payload = { user_id: user.id }
      session = JWTSessions::Session.new(payload: payload, refresh_by_access_allowed: true)

      tokens = session.login
      response.set_cookie(JWTSessions.access_cookie,
                          value: tokens[:access],
                          httponly: true,   #means that javascript of that page can't look into this information in the cookie. so attacks are prevented
                          secure: Rails.env.production?,   #sirf https par kaam karega
                          same_site: Rails.env.production? ? :none : :lax,   # works only when the site is secure (https) (had to do to because both out backend and frontend are running on different servers)
                          path: '/')
      render json: { csrf: tokens[:csrf] }
    else
      Rails.logger.warn("Invalid login attempt for email: #{params[:email]}")
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end


  def destroy
    begin
      session = JWTSessions::Session.new(payload: payload)
      session.flush_by_access_payload
      render json: :ok
    rescue JWTSessions::Errors::Unauthorized => e
      Rails.logger.info("Failed to logout: #{e.message}")
      render json: { error: 'Not authorized' }, status: :unauthorized
    end
  end
end

#this will also work fine as from frontend we are anyway deleting the csrf n all (just the sessions won't destroy)

# def destroy
#   render json: :ok
# end

# the following is very same to the before_action :authorize_access_request! logic applied on top. ugar vo nai bhi likhenge to yahan se vo cheeze check ho jaaegi
#   def destroy
#     if Rails.env.production?
#       begin
#         session = JWTSessions::Session.new(payload: access_payload)
#         session.flush_by_access_payload
#         Rails.logger.info("User #{access_payload[:user_id]} logged out")
#         render json: :ok
#       rescue JWTSessions::Errors::Unauthorized => e
#         Rails.logger.info("Failed to logout: #{e.message}")
#         render json: { error: 'Not authorized' }, status: :unauthorized
#       end
#     else
#
#     end
#
#   end
#
#   private
#
#   def access_payload
#     token = request.cookies[JWTSessions.access_cookie]
#     Rails.logger.info("Access token: #{token}")
#     payload = JWTSessions::Token.decode(token)[:ok]
#     Rails.logger.info("Access payload: #{payload}")
#     payload
#   rescue JWTSessions::Errors::Unauthorized => e
#     Rails.logger.error("Token decode error: #{e.message}")
#     nil
#   end
# end

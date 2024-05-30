class SigninController < ApplicationController
  # before_action :authorize_access_request!, only: [:destroy]

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      payload = { user_id: user.id }
      session = JWTSessions::Session.new(payload: payload, refresh_by_access_allowed: true)
      Rails.logger.info("signin-create-> payload=#{payload}  ---  session=#{session}, ")

      tokens = session.login
      # Rails.logger.info("current_user = #{current_user.payload}")
      response.set_cookie(JWTSessions.access_cookie,
                          value: tokens[:access],
                          httponly: true,   #means that javascript of that page can't look into this information in the cookie. so attacks are prevented
                          secure: Rails.env.production?,
                          same_site: :none,
                          path: '/')
      Rails.logger.info("Set-Cookie header: #{response.get_header('Set-Cookie')}")
      Rails.logger.info("respnse headers are set correctly #{response.header}")
      Rails.logger.info("signin-create-> cookies=#{response.cookies}")

      Rails.logger.info("User #{user.id} logged in with tokens: #{tokens}")
      render json: { csrf: tokens[:csrf] }
    else
      Rails.logger.warn("Invalid login attempt for email: #{params[:email]}")
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  # def destroy
  #   Rails.logger.info("inside the destroy method")
  #   render json: :ok
    # token = request.cookies[JWTSessions.access_cookie]
    # Rails.logger.info("access_cookie => #{JWTSessions::Token.decode(token)} ------- #{payload}")
    # if Rails.env.production?
    #   token = request.cookies[JWTSessions.access_cookie]
    #   Rails.logger.info("access_cookie => #{JWTSessions::Token.decode(token)} ------- #{payload}")
    #   begin
    #     session = JWTSessions::Session.new(payload: access_payload)
    #     session.flush_by_access_payload
    #     Rails.logger.info("User #{access_payload[:user_id]} logged out")
    #     render json: :ok
    #   rescue JWTSessions::Errors::Unauthorized => e
    #     Rails.logger.info("Failed to logout: #{e.message}")
    #     render json: { error: 'Not authorized' }, status: :unauthorized
    #   end
    # else
    #   token = request.cookies[JWTSessions.access_cookie]
    #
    #   Rails.logger.info("access_cookie => #{JWTSessions::Token.decode(token)} ------- #{payload}")
    #   session = JWTSessions::Session.new(payload: payload)
    #   session.flush_by_access_payload
    #   render json: :ok
    # end
  # end

    def destroy
      if Rails.env.production?
        begin
          session = JWTSessions::Session.new(payload: payload)
          session.flush_by_access_payload
          Rails.logger.info("User #{access_payload[:user_id]} logged out")
          render json: :ok
        rescue JWTSessions::Errors::Unauthorized => e
          Rails.logger.info("Failed to logout: #{e.message}")
          render json: { error: 'Not authorized' }, status: :unauthorized
        end
      else

      end

    end


  private

  def access_payload
    token = request.cookies[JWTSessions.access_cookie]
    Rails.logger.info("Access token: #{token}")
    payload = JWTSessions::Token.decode(token)[:ok]
    Rails.logger.info("Access payload: #{payload}")
    payload
  rescue JWTSessions::Errors::Unauthorized => e
    Rails.logger.error("Token decode error: #{e.message}")
    nil
  end
end


#this will also work fine as from frontend we are anyway deleting the csrf n all (just the sessions won't destroy)

# def destroy
#   render json: :ok
# end




#
# class SigninController < ApplicationController
#   before_action :authorize_access_request!, only: [:destroy]
#
#   def create
#     user = User.find_by(email: params[:email])
#     if user&.authenticate(params[:password])
#       payload = { user_id: user.id }
#       session = JWTSessions::Session.new(payload: payload, refresh_by_access_allowed: true)
#       tokens = session.login
#       response.set_cookie(JWTSessions.access_cookie,
#                           value: tokens[:access],
#                           httponly: true,
#                           secure: Rails.env.production?)
#
#       Rails.logger.info("User #{user.id} logged in with tokens: #{tokens}")
#       render json: { csrf: tokens[:csrf] }
#     else
#       Rails.logger.warn("Invalid login attempt for email: #{params[:email]}")
#       render json: { error: 'Invalid email or password' }, status: :unauthorized
#     end
#   end
#
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

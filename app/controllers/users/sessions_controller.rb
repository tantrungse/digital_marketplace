# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  include RackSessionsFix

  respond_to :json

  def create
    user = User.find_for_database_authentication(email: params[:user][:email])

    if user&.valid_password?(params[:user][:password])
      role_name = params[:user][:role].to_s.downcase

      if user.roles.exists?(name: role_name)
        sign_in(user)
        render_success_response(user)
      else
        render json: {
          status: 403,
          message: "Role '#{role_name}' not authorized for this user."
        }, status: :forbidden
      end

    else
      render json: {
        status: 401,
        message: 'Invalid email or password.'
      }, status: :unauthorized
    end
  end

  private

  def render_success_response(user)
    render json: {
      status: {
        code: 200, message: 'Logged in successfully.',
        data: { user: UserSerializer.new(user).serializable_hash[:data] }
      }
    }, status: :ok
  end

  def respond_to_on_destroy
    if current_user
      render json: {
        status: 200,
        message: 'Logged out successfully.'
      }, status: :ok
    else
      render json: {
        status: 401,
        message: "Couldn't find an active session."
      }, status: :unauthorized
    end
  end
end

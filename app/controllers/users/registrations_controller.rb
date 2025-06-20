# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  include RackSessionsFix

  respond_to :json

  private

  def sign_up(resource_name, resource)
    super
    begin
      assign_role_to_user(resource)
    rescue ActiveRecord::RecordInvalid => e
      resource.destroy
      render json: {
        status: { message: "Signup failed: #{e.message}" }
      }, status: :unprocessable_entity
    end
  end

  def assign_role_to_user(user)
    role_name = params[:user][:role]
    raise ActiveRecord::RecordInvalid.new(user) if role_name.blank?

    role = Role.find_by(name: role_name.downcase)
    if role.nil?
      raise ActiveRecord::RecordInvalid.new(user), "Role '#{role_name}' not found"
    end

    user.roles << role unless user.roles.include?(role)
  end

  def respond_with(current_user, _opts = {})
    if resource.persisted?
      render json: {
        status: {code: 200, message: 'Signed up successfully.'},
        data: UserSerializer.new(current_user).serializable_hash[:data]
      }
    else
      render json: {
        status: {message: "User couldn't be created successfully. #{current_user.errors.full_messages.to_sentence}"}
      }, status: :unprocessable_entity
    end
  end
end

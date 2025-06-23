class UserSerializer
  include JSONAPI::Serializer
  attributes :id, :email, :first_name, :last_name
  attribute :roles do |user|
    user.roles.pluck(:name)
  end

  has_many :roles
end

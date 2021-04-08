class UserSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :email, :firstname, :lastname, :created_at
  attribute :avatar do |object|
    ActiveStorage::Blob.service.path_for(object.avatar.key) if object.avatar.attached?
  end

  has_many :subjects
  has_many :user_classes_subjects
end

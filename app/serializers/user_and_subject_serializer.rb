# frozen_string_literal: true

# UserAndSubjectSerializer
class UserAndSubjectSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :created_at

  attribute :user do |object|
    {
      id: object.user.id,
      first_name: object.user.firstname,
      last_name: object.user.lastname,
      created_at: object.user.created_at
    }
  end

  attribute :subject do |object|
    {
      id: object.subject.id,
      name: object.subject.name,
      created_at: object.subject.created_at
    }
  end
end

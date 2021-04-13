# frozen_string_literal: true

# SubjectAndClassSerializer
class SubjectAndClassSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :created_at
  attribute :subject do |object|
    {
      id: object.subject.id,
      name: object.subject.name,
      created_at: object.subject.created_at,
      updated_at: object.subject.updated_at
    }
  end

  attribute :teaching_class do |object|
    {
      id: object.teaching_class.id,
      name: object.teaching_class.name,
      created_at: object.teaching_class.created_at,
      updated_at: object.teaching_class.updated_at
    }
  end
end

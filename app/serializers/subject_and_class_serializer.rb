# frozen_string_literal: true

# SubjectAndClassSerializer
class SubjectAndClassSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :created_at, :subject, :teaching_class

  def subject
    object.subject.collect do |subj|
      {
        id: subj.id,
        name: subj.name
      }
    end
  end

  def teaching_class
    object.teaching_class.collect do |cls|
      {
        id: cls.id,
        name: cls.name
      }
    end
  end
end

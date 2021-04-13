# frozen_string_literal: true

class SubjectAndClassPolicy < Struct.new(:user, :subject_and_class)

  def create?
    user.admin?
  end

  def remove_subject_and_classes?
    user.admin?
  end
end

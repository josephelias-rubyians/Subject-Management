# frozen_string_literal: true

class UserClassesSubjectPolicy < Struct.new(:user, :user_classes_subject)

  def create?
    user.admin?
  end

  def remove_user_classes_subjects?
    user.admin?
  end
end

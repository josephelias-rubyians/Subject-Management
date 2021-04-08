# frozen_string_literal: true

class UserClassesSubject < ApplicationRecord
  belongs_to :subject
  belongs_to :teaching_class
  belongs_to :user

  validates_uniqueness_of :user_id, scope: %i[teaching_class_id subject_id],
                                    message: 'Class and subject already assigned.'
end

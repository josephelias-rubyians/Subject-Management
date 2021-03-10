class UserClassesSubject < ApplicationRecord
  belongs_to :subject
  belongs_to :teaching_class
  belongs_to :user
end

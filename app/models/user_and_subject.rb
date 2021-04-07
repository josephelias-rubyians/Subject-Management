class UserAndSubject < ApplicationRecord
  belongs_to :subject
  belongs_to :user

  validates_uniqueness_of :subject_id, scope: :user_id
end

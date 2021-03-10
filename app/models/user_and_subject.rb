class UserAndSubject < ApplicationRecord
  belongs_to :subject
  belongs_to :user
end

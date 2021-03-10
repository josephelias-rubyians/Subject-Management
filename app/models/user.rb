class User < ApplicationRecord
	has_many :user_and_subjects
	has_many :subjects, through: :user_and_subjects
	has_many :user_classes_subjects

end

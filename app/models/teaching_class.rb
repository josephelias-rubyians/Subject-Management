class TeachingClass < ApplicationRecord
	has_many :sub_and_classes
	has_many :subjects, through: :sub_and_classes

end

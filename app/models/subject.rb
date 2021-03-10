class Subject < ApplicationRecord
	has_many :sub_and_classes
	has_many :teaching_classes, through: :sub_and_classes

end

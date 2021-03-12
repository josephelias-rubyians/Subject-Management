class Subject < ApplicationRecord
	has_many :sub_and_classes, dependent: :destroy
	has_many :teaching_classes, through: :sub_and_classes

	validates :name, presence: true

end

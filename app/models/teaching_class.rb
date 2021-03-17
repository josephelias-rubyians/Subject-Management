class TeachingClass < ApplicationRecord
	has_many :sub_and_classes, dependent: :destroy
	has_many :subjects, through: :sub_and_classes

	validates :name, presence: true

end

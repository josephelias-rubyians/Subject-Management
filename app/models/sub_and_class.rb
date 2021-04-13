class SubAndClass < ApplicationRecord
  belongs_to :subject
  belongs_to :teaching_class

  validates_uniqueness_of :subject_id, scope: :teaching_class_id
end

class TeachingClassSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id, :name, :created_at
  has_many :subjects
  
end

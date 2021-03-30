# frozen_string_literal: true

FactoryBot.define do
  factory :teaching_class do
  	sequence(:name) {|n| "Class - #{n}" }
  end
end

# frozen_string_literal: true

require 'faker'
require 'factory_bot_rails'

module TeachingClassHelpers
  def create_teaching_class
    FactoryBot.create(:teaching_class)
  end
end

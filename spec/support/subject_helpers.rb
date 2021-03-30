# frozen_string_literal: true

require 'faker'
require 'factory_bot_rails'

module SubjectHelpers
  def create_subject
    FactoryBot.create(:subject)
  end
end

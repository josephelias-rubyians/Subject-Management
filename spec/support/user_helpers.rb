require 'faker'
require 'factory_bot_rails'

module UserHelpers

  def create_user
    FactoryBot.create(:user, 
			email: Faker::Internet.email, 
			password: Faker::Internet.password,
			firstname: Faker::Name.first_name,
      lastname: Faker::Name.last_name,
      age: Faker::Number.number(digits: 2)
		)
  end

	def build_user
    FactoryBot.build(:user, 
			email: Faker::Internet.email, 
			password: Faker::Internet.password,
			firstname: Faker::Name.first_name,
      lastname: Faker::Name.last_name,
      age: Faker::Number.number(digits: 2)
		)
  end

end

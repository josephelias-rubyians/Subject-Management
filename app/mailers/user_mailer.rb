class UserMailer < ActionMailer::Base
  default :from => ENV['DEFAULT_MAIL_FROM']

	def registration_successful(user)
	  @user = user
	  mail(:to => "#{user.firstname} <#{user.email}>", :subject => "Registration Successful")
	end

end

class UserMailer < ActionMailer::Base
  default :from => Rails.application.credentials.dig(:default_mail_from)

	def registration_successful(user)
	  @user = user
	  mail(:to => "#{user.firstname} <#{user.email}>", :subject => "Registration Successful")
	end

end

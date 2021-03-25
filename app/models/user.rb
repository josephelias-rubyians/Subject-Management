class User < ApplicationRecord
	attr_accessor :current_password
	after_create :send_email_to_user
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtBlacklist

	has_many :user_and_subjects, dependent: :destroy
	has_many :subjects, through: :user_and_subjects
	has_many :user_classes_subjects, dependent: :destroy

	has_one_attached :avatar

	validates :email, :password, presence: true, on: :create
	validates :email, email: true, on: :create
	validates :password, length: { in: 6..20 }, on: :create

	private
	
	def send_email_to_user
		begin
      UserMailer.registration_successful(self).deliver
    rescue Net::SMTPAuthenticationError, Net::SMTPServerBusy, Net::SMTPSyntaxError, Net::SMTPFatalError, Net::SMTPUnknownError, SocketError => e
      Rails.logger.error("Failed to send mail...")
    end
	end

end

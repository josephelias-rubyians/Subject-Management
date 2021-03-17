class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtBlacklist

	has_many :user_and_subjects, dependent: :destroy
	has_many :subjects, through: :user_and_subjects
	has_many :user_classes_subjects, dependent: :destroy

	validates :email, :password, presence: true
	validates :email, email: true
	validates :password, length: { in: 6..20 }

end

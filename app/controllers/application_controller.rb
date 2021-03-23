class ApplicationController < ActionController::API
	include Pundit
	rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

	def user_not_authorized(exception)
		policy_name = exception.policy.class.to_s.underscore
		msg = I18n.t("#{policy_name}.#{exception.query}", scope: "pundit", default: :default)
		render json: {error: "#{msg}"}, status: 400
	end

end

# frozen_string_literal: true

# Application controller class inherits from API class
class ApplicationController < ActionController::API
  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  # Returns error message when user in not authorized
  def user_not_authorized(exception)
    policy_name = exception.policy.class.to_s.underscore
    msg = I18n.t("#{policy_name}.#{exception.query}", scope: 'pundit', default: :default)
    render json: { error: msg.to_s }, status: 400
  end
end

# frozen_string_literal: true

class UserPolicy
  attr_reader :current_user, :model

  def initialize(current_user, model)
    @current_user = current_user
    @user = model
  end

  def show?
    action_performable?
  end

  def update?
    action_performable?
  end

  def destroy?
    action_performable?
  end

  def update_password?
    action_performable?
  end

  def action_performable?
    return true if @current_user.admin?

    @user == @current_user
  end
end

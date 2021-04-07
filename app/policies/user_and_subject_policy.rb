# frozen_string_literal: true

class UserAndSubjectPolicy
  attr_reader :current_user, :model

  def initialize(current_user, model)
    @current_user = current_user
    @user = model.user
  end

  def create?
    action_performable?
  end

  def remove_user_and_subjects?
    action_performable?
  end

  def action_performable?
    return true if @current_user.admin?

    @user == @current_user
  end
end
# frozen_string_literal: true

class TeachingClassPolicy
  attr_reader :current_user, :model

  def initialize(current_user, model)
    @current_user = current_user
    @teaching_class = model
  end

  def create?
    @current_user.admin?
  end

  def update?
    @current_user.admin?
  end

  def destroy?
    @current_user.admin?
  end
end

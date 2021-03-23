class UserPolicy

	attr_reader :current_user, :model

  def initialize(current_user, model)
    @current_user = current_user
    @user = model
  end

  def index?
    @current_user.admin? ? User.all : @current_user
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

  def action_performable?
  	if (@user == @current_user) && !(@current_user.admin?)
  		true
  	elsif !(@user == @current_user) && !(@current_user.admin?)
  		false
  	else
  		true
  	end
  end

end

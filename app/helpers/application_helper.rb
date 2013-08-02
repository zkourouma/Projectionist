module ApplicationHelper
  def current_user
    @current_user ||= User.find_by_token
  end
end

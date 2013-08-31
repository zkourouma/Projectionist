class RegistrationsController < Devise::RegistrationsController
  def edit
    @user = current_user
    @company = @user.company
    @projects = @company.projects
    super
  end

  protected

  def after_sign_up_path_for(resource)
    '/user/company/new'
  end
end
class RegistrationsController < Devise::RegistrationsController
  before_filter :add_projects, only: [:edit]

  protected

  def after_sign_up_path_for(resource)
    '/user/company/new'
  end

  def add_projects
    @projects = current_user.company.projects
    @projects = nil if @projects.empty?
  end
end
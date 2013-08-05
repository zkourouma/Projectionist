class CompaniesController < ApplicationController

  def new
    @industries = Industry.all
  end

  def create
    params[:company][:user_id] = current_user.id
    @company = Company.new(params[:company])
    if @company.save
      redirect_to new_user_company_income_statement_url
    else
      flash.notice = "Could not save company"
      render :new
    end
  end

  def edit
  end

  def destroy
  end

  def show
    @user = current_user
    @company = @user.company
    # @projects = @company.projects
  end
end

class CompaniesController < ApplicationController

  def new
  end

  def create
    params[:company][:user_id] = current_user.id
    @company = Company.new(params[:company])
  end

  def edit
  end

  def destroy
  end
end

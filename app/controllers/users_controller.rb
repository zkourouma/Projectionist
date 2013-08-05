class UsersController < ApplicationController

  def new
  end

  def create
  end

  def show
    @user = current_user
  end

  def edit
  end
end

class CompaniesController < ApplicationController

  def new
    @industries = Industry.all
    @assumes = @@assumption_list.map{|ass| Assumption.new(metric_name: ass)}
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
    @user = current_user
    @company = @user.company
    @assumptions = @company.assumptions
    @industries = @company.industries
    @industrials = Industry.all
    @assumes = @@assumption_list.map{|ass| Assumption.new(metric_name: ass)}
  end

  def update
    @company = Company.find_by_user_id(current_user.id)
    if @company.update_attributes(params[:company])
      redirect_to user_company_url
    else
      flash.notice = "Could not update"
      @user = current_user
      @assumptions = @company.assumptions
      @industries = @company.industries
      @industrials = Industry.all
      @assumes = @@assumption_list.map{|ass| Assumption.new(metric_name: ass)}
      render :edit
    end
  end

  def destroy
  end

  def show
    @user = current_user
    @company = @user.company
    @assumptions = @company.assumptions
    @projects = @company.projects
    @projects = nil if @projects.empty?
  end
  @@assumption_list = ["revs", "gross_profit", "gross_margin", "operating_profit",
    "operating_margin", "ebitda", "ebitda_margin", "net_income", "eps", "fcf", "cogs",
    "cash", "inventory", "receivables", "payables", "ppe", "capex", "opex", "std", "ltd"]
end


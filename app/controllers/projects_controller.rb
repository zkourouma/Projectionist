class ProjectsController < ApplicationController
  def new
    @company = current_user.company
    @projects = @company.projects
    @projects = nil if @projects.empty?
    @list = @@assumption_list.map{|ass| Assumption.new(metric_name: ass)}
    @start_time = new_quarter.first
  end

  def create
    params[:project][:user_id] = current_user.id
    params[:project][:company_id] = current_user.company.id
    @project = Project.new(params[:project])

    if @project.save
      redirect_to user_project_url(@project)
    else
      flash.notice = "Could not save project"
      render :new
    end
  end

  def edit
    @project = Project.find(params[:id])
    @list = @@assumption_list.map{|ass| Assumption.new(metric_name: ass)}
    @start_time = new_quarter.first
    @assumptions = @project.assumptions
    @metrics = @project.metrics
    @user = current_user
    @projects = @user.company.projects
  end

  def update
    @project = Project.find(params[:id])
    if @project.update_attributes(params[:project])
      redirect_to user_project_url(@project)
    else
      flash.notice = "Could not update"
      @user = current_user
      @assumptions = @project.assumptions
      @metrics = @project.metrics
      @start_time = new_quarter.first
      @list = @@assumption_list.map{|ass| Assumption.new(metric_name: ass)}
      render :edit
    end
  end

  def show
    @user = current_user
    @project = Project.find(params[:id])
    @projects = @user.company.projects
    @assumptions = @project.assumptions
    @metrics = @project.metrics
    @start_time = new_quarter.first
    @list = @@assumption_list.map{|ass| Assumption.new(metric_name: ass)}
  end

  @@assumption_list = ["revs", "cogs", "rd","sga", "interest", "tax", "cash",
    "inventory", "receivables", "payables", "ppe", "lti", "std", "ltd",
    "goodwill", "amortization", "common_price", "common_quantity",
    "preferred_price", "preferred_quantity", "treasury_price", "treasury_quantity",
    "depreciation", "investments", "divs_paid", "stock_financing", "debt_financing"]
end

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
    @company = @user.company
    @projects = @company.projects
    @assumptions, @metrics = @project.assumptions, @project.metrics
    @start_time = new_quarter.first
    gon.data = data_cleanse(@metrics)
    @impact = @project.project_impact(@metrics, build_metric_tree(@company))
    @list = @@assumption_list.map{|ass| Assumption.new(metric_name: ass)}
  end

  def data_cleanse(metrics)
#   Converts the metric tree into an array of arrays that is more JS friendly
#   for the chart
    depth = metrics.map{|m| m.quarter }.uniq.length + 1
    data = Array.new(depth, Array.new)
    
    prehash = Hash.new
    prehash[:headers] = ['Quarter']
    
    metrics.each do |m|
      prehash[:headers] << m.display_name unless prehash[:headers].include?(m.display_name)
      prehash[m.quarter]||= ["#{m.quarter}Q#{m.year}"]
      prehash[m.quarter] << m.value
    end

    data[0] = prehash[:headers]

    prehash.each_with_index do |(key, value), i|
      next if i == 0
      data[i] = value
    end
    data
  end

  @@assumption_list = ["revs", "cogs", "rd","sga", "interest", "tax", "cash",
    "inventory", "receivables", "payables", "ppe", "lti", "std", "ltd",
    "goodwill", "amortization", "common_price", "common_quantity",
    "preferred_price", "preferred_quantity", "treasury_price", "treasury_quantity",
    "depreciation", "investments", "divs_paid", "stock_financing", "debt_financing"]
end

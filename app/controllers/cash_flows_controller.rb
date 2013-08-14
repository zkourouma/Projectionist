class CashFlowsController < ApplicationController

  def new
    @quarters = new_quarter[1..-1]
  end

  def create
    params[:cashflow][:company_id] = current_user.company.id
    @cashflow = CashFlow.new(params[:cashflow])

    if @cashflow.save
      redirect_to user_company_url
    else
      flash.notice = "Could not save balance sheet"
      render :new
    end
  end

  def show
    @user = current_user
    @quarters = new_quarter
    @company = current_user.company
    @projects = @company.projects
    @projects = nil if @projects.empty?
    @assumptions = @company.assumptions.select do |ass|
      CashFlow.relevant.has_key?(ass.metric_name.to_sym)
    end
    @cash_flow = @company.cashflow
    @metric_tree = build_metric_tree(@company)
    forecaster = forecast(@metric_tree, @assumptions)
    @metric_tree.each do |metric, years|
      years.each do |year, quarters|
        quarters.merge!(forecaster[metric][year]){|key, v1, v2| v1}
      end
    end
    chart_data = charter(@metric_tree, CashFlow.relevant, @quarters)
    gon.columns, gon.details = chart_data.first, chart_data[1..-1]
    @list_items = gen_item_list(@cash_flow)
  end

  def edit
    @year, @quarter = params[:year].to_i, params[:quarter].to_i
    @company = current_user.company
    @cashflow = @company.cashflow
    @metric_tree = build_metric_tree(@company)
    @surplus = @metric_tree.length + 1
  end

  def update
    @cashflow = current_user.company.cashflow
    if @income.update_attributes(params[:cashflow])
      redirect_to user_company_cash_flow_url
    else
      flash.notice = "Could not update quarter"
      redirect_to edit_user_company_cash_flow_url
    end
  end

  def add
    render :add
  end

  def add_year
    @cashflow = current_user.company.cashflow
    params[:cashflow][:metrics_attributes].each do |metric, value|
      value[:year] = params[:set_year].to_i
    end
    if @cashflow.update_attributes(params[:cashflow])
      redirect_to user_company_cash_flow_url
    else
      flash.notice = "Something went wrong"
      render :add
    end
  end


  private
  def gen_item_list(cash_flow)
    list = []
    cash_flow.metrics.each do |metric|
      list << metric.name unless list.include?(metric.name)
    end
    list.map!{|metric| [metric, CashFlow.relevant[metric.to_sym]]}
  end
end

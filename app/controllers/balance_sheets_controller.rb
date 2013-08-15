class BalanceSheetsController < ApplicationController

  def new
    @quarters = new_quarter[1..-1]
    @list_items = BalanceSheet.relevant
  end

  def create
    params[:balance][:company_id] = current_user.company.id
    @balance = BalanceSheet.new(params[:balance])

    if @balance.save
      redirect_to new_user_company_cash_flow_url
    else
      flash.notice = "Could not save balance sheet"
      render :new
    end
  end

  def show
    @quarters = new_quarter
    @company = current_user.company
    @assumptions = @company.assumptions.select do |ass|
      BalanceSheet.relevant.has_key?(ass.metric_name.to_sym)
    end
    @balance = @company.balance
    @metric_tree = build_metric_tree(@company)
    forecaster = forecast(@metric_tree, @assumptions)
    @metric_tree.each do |metric, years|
      years.each do |year, quarters|
        quarters.merge!(forecaster[metric][year]){|key, v1, v2| v1}
      end
    end
    chart_data = charter(@metric_tree, BalanceSheet.relevant, @quarters)
    gon.columns, gon.details = chart_data.first, chart_data[1..-1]
    @list_assumptions = gen_assumption_list(@balance)
  end

  def edit
    @year, @quarter = params[:year].to_i, params[:quarter].to_i
    @company = current_user.company
    @balance = @company.balance
    @metric_tree = build_metric_tree(@company)
    @surplus = @metric_tree.length + 1
    @full_statement = complete_statement?(@metric_tree, @year, @quarter, BalanceSheet.relevant)
  end

  def update
    @balance = current_user.company.balance
    if @income.update_attributes(params[:balance])
      redirect_to user_company_balance_sheet_url
    else
      flash.notice = "Could not update quarter"
      redirect_to edit_user_company_balance_sheet_url
    end
  end

  def add
    @list_items = BalanceSheet.relevant
    render :add
  end

  def add_year
    @balance = current_user.company.balance
    params[:balance][:metrics_attributes].each do |metric, value|
      value[:year] = params[:set_year].to_i
    end
    if @balance.update_attributes(params[:balance])
      redirect_to user_company_balance_sheet_url
    else
      flash.notice = "Something went wrong"
      render :add
    end
  end


  private
  def gen_assumption_list(balance_sheet)
    list = []
    balance_sheet.metrics.each do |metric|
      list << metric.name unless list.include?(metric.name)
    end
    list.map!{|metric| [metric, BalanceSheet.relevant[metric.to_sym]]}
  end
end
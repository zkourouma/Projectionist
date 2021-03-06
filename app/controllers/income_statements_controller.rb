class IncomeStatementsController < ApplicationController

  def new
    @quarters = new_quarter[1..-1]
    @list_items = IncomeStatement.relevant
  end

  def create
    params[:income][:company_id] = current_user.company.id
    @income = IncomeStatement.new(params[:income])

    if @income.save
      redirect_to new_user_company_balance_sheet_url
    else
      flash.notice = "Could not save income statement"
      render :new
    end
  end

  def show
    @quarters = new_quarter
    @company = current_user.company
    @assumptions = @company.assumptions.select do |ass|
      IncomeStatement.relevant.has_value?(ass.name)
    end
    @income = @company.income
    @metric_tree = build_metric_tree(@company)
    forecaster = forecast(@metric_tree, @assumptions)
    @metric_tree.each do |metric, years|
      years.each do |year, quarters|
        quarters.merge!(forecaster[metric][year]){|key, v1, v2| v1}
      end
    end
    chart_data = charter(@metric_tree, IncomeStatement.relevant, @quarters)
    gon.columns, gon.details = chart_data.first, chart_data[1..-1]
    @list_assumptions = gen_item_list(@income)
  end

  def edit
    @year, @quarter = params[:year].to_i, params[:quarter].to_i
    @company = current_user.company
    @income = @company.income
    @metric_tree = build_metric_tree(@company)
    @surplus = @metric_tree.length + 1
    @full_statement = complete_statement?(@metric_tree, @year, @quarter, IncomeStatement.relevant)
  end

  def update
    @income = current_user.company.income
    if @income.update_attributes(params[:income])
      redirect_to user_company_income_statement_url
    else
      flash.notice = "Could not update quarter"
      redirect_to edit_user_company_income_statement_url
    end
  end

  def add
    @list_items = IncomeStatement.relevant
    render :add
  end

  def add_year
    @company = current_user.company
    @income = @company.income
    @metric_tree = build_metric_tree(@company)
    params[:income][:metrics_attributes].each do |metric_num, new_met|
      new_met[:year] = params[:set_year].to_i
      p new_met
      next if new_met[:value].blank?
      metric_details = {name: new_met[:name], year: new_met[:year], 
                      quarter: new_met[:quarter], statementable_type: "IncomeStatement",
                      statementable_id: @income.id}
      remove_dup(Metric.new(metric_details), build_metric_tree(@company))
    end

    if @income.update_attributes(params[:income])
      redirect_to user_company_income_statement_url
    else
      flash.notice = "Something went wrong"
      render :add
    end
  end

  private
  def gen_item_list(income_statement)
    list = []
    income_statement.metrics.each do |metric|
      list << metric.name unless list.include?(metric.name)
    end
    list.map!{|metric| [metric, IncomeStatement.relevant[metric.to_sym]]}
  end
end
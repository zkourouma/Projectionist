class IncomeStatementsController < ApplicationController

  def new
    @quarters = new_quarter
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
    @user = current_user
    @quarters = new_quarter
    @company = current_user.company
    @assumptions = @company.assumptions.select do |ass|
      IncomeStatement.assumptions.has_key?(ass.metric_name.to_sym)
    end
    @income = @company.income
    @metric_tree = build_metric_tree(@income)
    @meta_stats = @income.build_metas
    # p @meta_stats
    p "_______________________"
    p @metric_tree
    p "_______________________ "
    @list_assumptions = gen_item_list(@income)
  end

  private
  def gen_item_list(income_statement)
    list = []
    income_statement.metrics.each do |metric|
      list << metric.name unless list.include?(metric.name)
    end
    list.map!{|metric| [metric, IncomeStatement.assumptions[metric.to_sym]]}
  end

end

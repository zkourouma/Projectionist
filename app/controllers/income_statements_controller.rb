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
    @list_assumptions = gen_item_list(@income)
  end

  def edit
    @year, @quarter = params[:year].to_i, params[:quarter].to_i
    @income = current_user.company.income
    @metric_tree = build_metric_tree(@income)
    @surplus = @metric_tree.length + 1
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

  private
  def gen_item_list(income_statement)
    list = []
    income_statement.metrics.each do |metric|
      list << metric.name unless list.include?(metric.name)
    end
    list.map!{|metric| [metric, IncomeStatement.assumptions[metric.to_sym]]}
  end

end

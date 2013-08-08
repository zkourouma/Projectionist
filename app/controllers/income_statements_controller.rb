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
      @@income_assumptions.has_key?(ass.metric_name.to_sym)
    end
    @income = @company.income
    @metric_tree = build_metric_tree(@income)
    @meta_stats = @income.build_metas
    p @meta_stats
    @list_assumptions = gen_assumption_list(@income)
  end

  private
  def gen_assumption_list(income_statement)
    list = []
    income_statement.metrics.each do |metric|
      list << metric.name unless list.include?(metric.name)
    end
    list.map!{|metric| [metric,
                        @@income_assumptions[metric.to_sym]]}
  end

  @@income_assumptions = {revs:"Revenue", gross_profit: "Gross Profit",
    gross_margin: "Gross Margin", operating_profit: "Operating Profit",
    operating_margin: "Operating Margin", ebitda: "EBITDA",
    ebitda_margin: "EBITDA Margin", net_income: "Net Income", eps: "EPS",
    cogs: "Cost of Goods Sold", opex: "Operating Expenses",
    sga: "SG&A Expense", tax: "Tax Expense",
    rd: "Research & Development"}
end

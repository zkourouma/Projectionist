class BalanceSheetsController < ApplicationController

  def new
    @quarters = new_quarter
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
    @user = current_user
    @quarters = new_quarter
    @company = current_user.company
    @assumptions = @company.assumptions.select do |ass|
      @@balance_assumptions.has_key?(ass.metric_name.to_sym)
    end
    @balance = @company.balance
    @metric_tree = build_metric_tree(@balance)
    @meta_stats = @balance.build_metas
    # p @meta_stats
    @list_assumptions = gen_assumption_list(@balance)
  end

  def edit
    @balance = current_user.company.balance
    @metric_tree = build_metric_tree(@balance)
    @year, @quarter = params[:year].to_i, params[:quarter].to_i
    @surplus = @metric_tree.length + 1
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
    list.map!{|metric| [metric, @@balance_assumptions[metric.to_sym]]}
  end

  @@balance_assumptions = {cash:"Cash", receivables: "Accounts Receivable",
    inventory: "Inventory", lti: "Long-Term Investments", ppe: "Property, Plant & Equipment",
    goodwill: "Goodwill", amortization: "Amortization", payables: "Accounts Payable",
    std: "Short-Term Debt", ltd: "Long-Term Debt", common_price: "Common Share Price",
    common_quantity: "Common Shares", preferred_price: "Preferred Share Price",
    preferred_quantity: "Preferred Shares", treasury_price: "Treasury Share Price",
    treasury_quantity: "Treasury Shares"}
end

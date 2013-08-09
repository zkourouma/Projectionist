class CashFlowsController < ApplicationController

  def new
    @quarters = new_quarter
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
    @assumptions = @company.assumptions.select do |ass|
      CashFlow.assumptions.has_key?(ass.metric_name.to_sym)
    end
    @cash_flow = @company.cashflow
    @metric_tree = build_metric_tree(@cash_flow)
    @meta_stats = @cash_flow.build_metas
    # p @meta_stats
    @list_items = gen_item_list(@cash_flow)
  end

  def edit
    @cashflow = current_user.company.cashflow
    @metric_tree = build_metric_tree(@cashflow)
    @year, @quarter = params[:year].to_i, params[:quarter].to_i
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

  private
  def gen_item_list(cash_flow)
    list = []
    cash_flow.metrics.each do |metric|
      list << metric.name unless list.include?(metric.name)
    end
    list.map!{|metric| [metric, CashFlow.assumptions[metric.to_sym]]}
  end
end

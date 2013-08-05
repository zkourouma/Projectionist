class CashFlowsController < ApplicationController

  def new
    @quarters = new_quarters
  end

  def create
    params[:cashflow][:company_id] = current_user.company.id
    @cashflow = CashFlow.new(params[:cashflow])

    if @cashflow.save
      redirect_to new_user_company_cash_flow_url
    else
      flash.notice = "Could not save balance sheet"
      render :new
    end
  end
end
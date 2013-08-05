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
end

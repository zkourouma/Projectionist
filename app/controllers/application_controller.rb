class ApplicationController < ActionController::Base
  include ApplicationHelper
  protect_from_forgery

  before_filter :authenticate_user!

  def after_sign_in_path_for(resource)
    user = current_user
    company = user.company
    if company
      if company.income
        if company.balance
          if company.cashflow
            current_user_path
          else
            new_user_company_cash_flow_path
          end
        else
          new_user_company_balance_sheet_path
        end
      else
        new_user_company_income_statement_path
      end
    else
      new_user_company_path
    end
  end

  def after_sign_out_path_for(resource)
    "/"
  end
end

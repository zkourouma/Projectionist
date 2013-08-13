class Assumption < ActiveRecord::Base
  attr_accessible :value, :company_id, :project_id, :metric_name,
                  :time_unit, :assumption_type

  belongs_to :company
  belongs_to :project

  def name
    case metric_name
    when "revs"
      "Revenue"
    when "cogs"
      "Cost of Goods Sold"
    when "depreciation"
      "Depreciation"
    when "amortization"
      "Amortization"
    when "inventory"
      "Inventory"
    when "receivables"
      "Accounts Receivable"
    when "payables"
      "Accounts Payable"
    when "ppe"
      "Property, Plant & Equipment"
    when "cash"
      "Cash"
    when "std"
      "Short-Term Debt"
    when "ltd"
      "Long-Term Debt"
    when "rd"
      "Research & Development"
    when "sga"
      "SG&A Expense"
    when "interest"
      "Interest Expense"
    when "tax"
      "Tax Expense"
    when "goodwill"
      "Goodwill"
    when "lti"
      "Long-Term Investments"
    when "common_price"
      "Common Share Price"
    when "common_quantity"
      "Common Shares"
    when "preferred_price"
      "Preferred Share Price"
    when "preferred_quantity"
      "Preferred Shares"
    when "treasury_price"
      "Treasury Share Price"
    when "treasury_quantity"
      "Treasure Shares"
    when "investments"
      "Investments"
    when "divs_paid"
      "Dividends Paid"
    when "stock_financing"
      "Stock Financing"
    when "debt_financing"
      "Debt Financing"
    end
  end

  def time
    case time_unit
    when "y"
      "year"
    when "q"
      "quarter"
    end
  end
end

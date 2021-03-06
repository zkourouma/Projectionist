class Metric < ActiveRecord::Base
  attr_accessible :name, :quarter, :year, :value, :statementable_id,
    :statementable_type, :forward

  belongs_to :statementable, polymorphic: true

  def display_name
    case name
    when "revs"
      "Revenue"
    when "gross_profit"
      "Gross Profit"
    when "gross_margin"
      "Gross Margin"
    when "operating_profit"
      "Operating Profit"
    when "operating_margin"
      "Operating Margin"
    when "ebitda"
      "EBITDA"
    when "ebitda_margin"
      "EBITDA Margin"
    when "net_income"
      "Net Income"
    when "eps"
      "Earnings per Share"
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
    when "capex"
      "Capital Expenditure"
    when "opex"
      "Operating Expenditure"
    when "cash"
      "Cash"
    when "std"
      "Short-Term Debt"
    when "ltd"
      "Long-Term Debt"
    when "fcf"
      "Free Cash Flow"
    when "stock_financing"
      "Stock Financing"
    when "debt_financing"
      "Debt Financing"
    when "divs_paid"
      "Dividends Paid"
    when "investments"
      "Investments"
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
      "Treasury Shares"
    when "goodwill"
      "Goodwill"
    when "lti"
      "Long-Term Investments"
    when "rd"
      "Research & Development"
    when "tax"
      "Tax Expense"
    when "interest"
      "Interest Expense"
    when "sga"
      "SG&A Expense"
    end
  end
end

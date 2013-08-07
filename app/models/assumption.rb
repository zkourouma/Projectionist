class Assumption < ActiveRecord::Base
  attr_accessible :value, :company_id, :project_id, :metric_name,
                  :timespan, :time_unit, :assumption_type

  belongs_to :company
  belongs_to :project

  def name
    case metric_name
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
      "Short Term Debt"
    when "ltd"
      "Long Term Debt"
    when "fcf"
      "Free Cash Flow"
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

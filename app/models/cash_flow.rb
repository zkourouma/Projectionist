class CashFlow < ActiveRecord::Base
  attr_accessible :company_id, :metrics, :metrics_attributes

  belongs_to :company
  has_many :metrics, as: :statementable
  accepts_nested_attributes_for :metrics, reject_if: proc { |att| att['value'].blank? }

  def operating_cash_flow(tree, quarter, year)
    i = company.income
    ebitda = i.ebitda(tree, quarter, year)
    b = company.balance
    working_delta = b.working_capital(tree, quarter, year) - 
                      b.working_capital(tree, quarter, year - 1)
    ebitda - working_delta
  end

  def free_cash_flow(tree, quarter, year)
    operating_cash_flow(tree, quarter, year) - capex(tree, quarter, year)
  end

  def free_cash_per_share(tree, quarter, year)
    commons = sanitize(tree, "Common Shares", year, quarter)
    treasuries = sanitize(tree, "Treasury Shares", year, quarter)
    preferreds = sanitize(tree, "Preferred Shares", year, quarter)
    shares = commons + preferreds + treasuries
    return 0 if shares == 0
    free_cash_flow(tree, quarter, year) / shares
  end

  def delta_receivables(tree, quarter, year)
    this = sanitize(tree, "Accounts Receivable", year, quarter)
    that = sanitize(tree, "Accounts Receivable", year-1, quarter)
    this - that
  end

  def delta_inventory(tree, quarter, year)
    this = sanitize(tree, "Inventory", year, quarter)
    that = sanitize(tree, "Inventory", year-1, quarter)
    this - that
  end

  def delta_liabilities(tree, quarter, year)
    std_this = sanitize(tree, "Short-Term Debt", year, quarter)
    std_that = sanitize(tree, "Short-Term Debt", year-1, quarter)

    ltd_this = sanitize(tree, "Long-Term Debt", year, quarter)
    ltd_that = sanitize(tree, "Long-Term Debt", year-1, quarter)

    pay_this = sanitize(tree, "Accounts Payable", year, quarter)
    pay_that = sanitize(tree, "Accounts Payable", year-1, quarter)

    std_this - std_that + ltd_this - ltd_that + pay_this - pay_that
  end

  def capex(tree, quarter, year)
    ppe_this = sanitize(tree, "Property, Plant & Equipment", year, quarter)
    ppe_that = sanitize(tree, "Property, Plant & Equipment", year-1, quarter)
    ppe_this - ppe_that
  end

  def sanitize(tree, name, year, quarter)
    if tree[name][year][quarter]
      tree[name][year][quarter].value
    else
      0
    end
  end

  def self.relevant
    @@relevant
  end

  @@operations_list = [:operating_cash_flow, :free_cash_flow, :free_cash_flow_per_share,
    :delta_receivables, :delta_inventory, :delta_liabilities, :capex]

  @@relevant = {depreciation:"Depreciation", investments: "Investments",
    divs_paid: "Dividends Paid", stock_financing: "Stock Financing",
    debt_financing: "Net Borrowings"}
end

class BalanceSheet < ActiveRecord::Base
  attr_accessible :company_id, :metrics_attributes

  belongs_to :company
  has_many :metrics, as: :statementable
  accepts_nested_attributes_for :metrics, reject_if: proc { |att| att['value'].blank? }

  @operations_list = [:debt_to_equity, :cash_per_share, :current_ratio, :book_value,
        :capex, :working_capital]

  @relevant = {cash:"Cash", receivables: "Accounts Receivable",
    inventory: "Inventory", lti: "Long-Term Investments", ppe: "Property, Plant & Equipment",
    goodwill: "Goodwill", amortization: "Amortization", payables: "Accounts Payable",
    std: "Short-Term Debt", ltd: "Long-Term Debt", common_price: "Common Share Price",
    common_quantity: "Common Shares", preferred_price: "Preferred Share Price",
    preferred_quantity: "Preferred Shares", treasury_price: "Treasury Share Price",
    treasury_quantity: "Treasury Shares"}

  def debt_to_equity(tree, quarter, year)
    std = sanitize(tree, "Short-Term Debt", year, quarter)
    ltd = sanitize(tree, "Long-Term Debt", year, quarter)
    
    commons = sanitize(tree, "Common Shares", year, quarter)
    common_p = sanitize(tree, "Common Share Price", year,quarter)
    
    treasuries = sanitize(tree, "Treasury Shares", year, quarter)
    treasury_p = sanitize(tree, "Treasury Share Price", year, quarter)
    
    preferreds = sanitize(tree, "Preferred Shares", year, quarter)
    preferred_p = sanitize(tree, "Preferred Share Price", year, quarter)

    debt = std + ltd
    c = commons * common_p
    t = treasuries * treasury_p
    p = preferreds * preferred_p
    equity_q = {commons: c, treasuries: t, preferreds: p}
    equity_t = 0
    equity_q.each do |name, value|
      equity_t += value
    end
    return 0 if equity_t == 0
    debt / equity_t
  end

  def cash_per_share(tree, quarter, year)
    commons = sanitize(tree, "Common Shares", year, quarter)
    treasuries = sanitize(tree, "Treasury Shares", year, quarter)
    preferreds = sanitize(tree, "Preferred Shares", year, quarter)
    shares = commons + preferreds + treasuries

    cash = sanitize(tree, "Cash", year, quarter)
    
    return 0 if shares == 0
    cash / shares
  end

  def current_ratio(tree, quarter, year)
    cash = sanitize(tree, "Cash", year, quarter)
    receive = sanitize(tree, "Accounts Receivable", year, quarter)
    inven = sanitize(tree, "Inventory", year, quarter)
    assets = cash + receive + inven
    
    debt = sanitize(tree, "Short-Term Debt", year, quarter)
    pay = sanitize(tree, "Accounts Payable", year, quarter)
    liabilities = debt + pay
    
    return 0 if liabilities == 0
    assets / liabilities
  end

  def book_value(tree, quarter, year)
    cash = sanitize(tree, "Cash", year, quarter)
    receive = sanitize(tree, "Accounts Receivable", year, quarter)
    inven = sanitize(tree, "Inventory", year, quarter)
    lti = sanitize(tree, "Long-Term Investments", year, quarter)
    ppe = sanitize(tree, "Property, Plant & Equipment", year, quarter)
    assets = cash + receive + inven + lti + ppe

    dep = sanitize(tree, "Depreciation", year, quarter)
    assets -= dep
    
    std = sanitize(tree, "Short-Term Debt", year, quarter)
    ltd = sanitize(tree, "Long-Term Debt", year, quarter)
    pay = sanitize(tree, "Accounts Payable", year, quarter)
    liabilities = std + ltd + pay
    
    assets - liabilities
  end

  def book_value_per_share(tree, quarter, year)
    val = book_value(tree, quarter,year)
    commons = sanitize(tree, "Common Shares", year, quarter)
    treasuries = sanitize(tree, "Treasury Shares", year, quarter)
    preferreds = sanitize(tree, "Preferred Shares", year, quarter)
    shares = commons + treasuries + preferreds
    return 0 if shares == 0
    val / shares
  end

  def capex(tree, quarter, year)
    this = sanitize(tree, "Property, Plant & Equipment", year, quarter)
    that = sanitize(tree, "Property, Plant & Equipment", year-1, quarter)
    this - that
  end

  def working_capital(tree, quarter, year)
    cash = sanitize(tree, "Cash", year, quarter)
    receive = sanitize(tree, "Accounts Receivable", year, quarter)
    inven = sanitize(tree, "Inventory", year, quarter)
    assets = cash + receive + inven
    
    debt = sanitize(tree, "Short-Term Debt", year, quarter)
    pay = sanitize(tree, "Accounts Payable", year, quarter)
    liabilities = debt + pay

    assets - liabilities
  end

  def sanitize(tree, name, year, quarter)
    if tree[name][year][quarter]
      tree[name][year][quarter].value
    else
      0
    end
  end

  def self.relevant
    @relevant
  end

  def self.operations
    @operations_list
  end
end

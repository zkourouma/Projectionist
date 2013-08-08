class BalanceSheet < ActiveRecord::Base
  attr_accessible :company_id, :metrics_attributes

  belongs_to :company
  has_many :metrics, as: :statementable
  accepts_nested_attributes_for :metrics, reject_if: proc { |att| att['value'].blank? }

  def debt_to_equity(quarter, year)
    tot = Metric.where(statementable_id: id, year: year, quarter: quarter,
                       name: ["std", "ltd", "common_quantity", "treasury_quantity", "preferred_quantity", "common_price", "treasury_price", "preferred_price"])
    debt = tot.select{ |el| ["std", "ltd"].include?(el.name)}.map(&:value).inject(:+)
    equity_q = tot.select{ |el| ["common_quantity", "preferred_quantity", "treasury_quantity"].include?(el.name)}
    equity_v = tot.select{ |el| ["common_price", "preferred_price", "treasury_price"].include?(el.name)}
    equity_t = 0
    equity_q.each do |quantity|
      equity_v.each do |value|
        if quantity.name[0,3] == value.name[0,3]
          equity_t += (quantity.value.to_f * value.value.to_f)
        end
      end
    end
    return 0 unless debt && (equity_t != 0)
    debt.to_f / equity_t
  end

  def cash_per_share(quarter, year)
    cashare = Metric.where(statementable_id: id, year: year, quarter: quarter,
                            name: ["cash", "treasury_quantity", "preferred_quantity", "common_quantity"])
    cash = cashare.find{|el| el.name = "cash"}
    shares = cashare.select{|el| el.name != "cash"}.map(&:value).inject(:+)
    return 0 unless cash && shares && (shares != 0)
    cash.value.to_f / shares.to_f
  end

  def current_ratio(quarter, year)
    tot = Metric.where(statementable_id: id, year: year, quarter: quarter,
                        name: ["cash", "receivables", "inventory",
                                "std", "payables"])
    assets = tot.select{|el| ["cash", "receivables", "inventory"].include?(el.name)}.map(&:value).inject(:+)
    liabilities = tot.select{|el| ["std", "payables"].include?(el.name)}.map(&:value).inject(:+)
    return 0 unless assets && liabilities
    if liabilities
      assets.to_f / liabilities.to_f
    else
      0
    end
  end

  def book_value(quarter, year)
    tot = Metric.where(statementable_id: id, year: year, quarter: quarter,
                       name: ["cash", "receivables", "lti", "inventory", "ppe",
                               "depreciation", "payables", "std", "ltd"])
    assets = tot.select{|el| ["cash", "receivables", "lti", "inventory", "ppe"].
                                include?(el.name)}.map(&:value).inject(:+)
    assets -= tot.find{|el| el.name == "depreciation"}.value
    liabilities = tot.select{|el| ["payables", "std", "ltd"].
                                include?(el.name)}.map(&:value).inject(:+)
    assets - liabilities
  end

  def book_value_per_share(quarter, year)
    val = book_value(quarter,year)
    shares = Metric.where(statementable_id: id, year: year, quarter: quarter,
                          name: ["common_quantity", "treasury_quantity", "preferred_quantity"])
    shares = shares.map(&:value).inject(:+)

    return 0 unless val
    shares ||= 0.0001
    val.to_f / shares
  end

  def capex(quarter, year)
    expend = Metric.where(statementable_id: id, year: [year, year - 1],
                          quarter: quarter, name: "ppe").sort{ |a,b| a.year <=> b.year}.
                          map(&:value)
    return 0 if expend.empty?
    expend[1] ||= 0
    expend[0] ||= 0
    expend[1] - expend[0]
  end

  def working_capital(quarter, year)
    tot = Metric.where(statementable_id: id, year: year, quarter: quarter,
                        name: ["cash", "receivables", "inventory",
                                "std", "payables"])
    assets = tot.select{|el| ["cash", "receivables", "inventory"].include?(el.name)}.map(&:value).inject(:+)
    liabilities = tot.select{|el| ["std", "payables"].include?(el.name)}.map(&:value).inject(:+)
    return 0 if tot.empty?
    assets ||= 0
    liabilities ||= 0
    assets - liabilities
  end

  def build_metas
    stats = []
    operations = []
    list = metrics
    @@operations_list.each do |op|
      # operations << op if @@income_assumptions.has_key
    end

  end

  def assumptions
    @@assumptions
  end

  @@operations_list = [:debt_to_equity, :cash_per_share, :current_ratio, :book_value,
        :capex, :working_capital]

  @@assumptions = {cash:"Cash", receivables: "Accounts Receivable",
    inventory: "Inventory", lti: "Long-Term Investments", ppe: "Property, Plant & Equipment",
    goodwill: "Goodwill", amortization: "Amortization", payables: "Accounts Payable",
    std: "Short-Term Debt", ltd: "Long-Term Debt", common_price: "Common Share Price",
    common_quantity: "Common Shares", preferred_price: "Preferred Share Price",
    preferred_quantity: "Preferred Shares", treasury_price: "Treasury Share Price",
    treasury_quantity: "Treasury Shares", depreciation:"Depreciation",
    investments: "Investments", divs_paid: "Dividends Paid", stock_financing: "Stock Financing",
    debt_financing: "Net Borrowings", revs:"Revenue", gross_profit: "Gross Profit",
    gross_margin: "Gross Margin", operating_profit: "Operating Profit",
    operating_margin: "Operating Margin", ebitda: "EBITDA",
    ebitda_margin: "EBITDA Margin", net_income: "Net Income", eps: "EPS",
    cogs: "Cost of Goods Sold", opex: "Operating Expenses",
    sga: "SG&A Expense", tax: "Tax Expense",
    rd: "Research & Development"}

end

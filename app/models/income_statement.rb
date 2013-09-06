class IncomeStatement < ActiveRecord::Base
  attr_accessible :company_id, :metrics_attributes

  belongs_to :company
  has_many :metrics, as: :statementable
  accepts_nested_attributes_for :metrics, reject_if: proc { |att| att['value'].blank? }

  @operations_list = {"Revenue" => [gross_profit: "Gross Profit",
                                    operating_profit: "Operating Profit",
                                    ebitda: "EBITDA", net_income: "Net Income",
                                    eps: "EPS", gross_margin: "Gross Margin",
                                    operating_margin: "Operating Margin",
                                    ebitda_margin: "EBITDA Margin"],
                        "Cost of Goods Sold" => [gross_profit: "Gross Profit",
                                    operating_profit: "Operating Profit",
                                    ebitda: "EBITDA", net_income: "Net Income",
                                    eps: "EPS", gross_margin: "Gross Margin",
                                    operating_margin: "Operating Margin",
                                    ebitda_margin: "EBITDA Margin"],
                        "SG&A Expense" => [operating_profit: "Operating Profit",
                                    ebitda: "EBITDA", net_income: "Net Income",
                                    eps: "EPS", operating_margin: "Operating Margin",
                                    ebitda_margin: "EBITDA Margin"],
                        "Research & Development" => [operating_profit: "Operating Profit",
                                    ebitda: "EBITDA", net_income: "Net Income",
                                    eps: "EPS", operating_margin: "Operating Margin",
                                    ebitda_margin: "EBITDA Margin"],
                        "Interest Expense" => [net_income: "Net Income", 
                                              eps: "EPS"],
                        "Tax Expense" => [net_income: "Net Income", eps: "EPS"]}

  @relevant = {revs:"Revenue", cogs: "Cost of Goods Sold", sga: "SG&A Expense",
    rd: "Research & Development", interest: "Interest Expense",
     tax: "Tax Expense"}

  def gross_profit(tree, quarter, year)
    revs = sanitize(tree, "Revenue", year, quarter)
    cogs = sanitize(tree, "Cost of Goods Sold", year, quarter)
    revs - cogs
  end

  def yoy_gross_profit_delta(tree, quarter, year)
    prev, cur = gross_profit(tree, quarter, year-1), gross_profit(tree, quarter, year)
    {absolute: (cur - prev), percent: ((cur - prev).to_f / prev) }
  end

  def operating_profit(tree, quarter, year)
    dep = sanitize(tree, "Depreciation", year, quarter)
    amor = sanitize(tree, "Amortization", year, quarter)
    gross_profit(tree, quarter, year) - opex(tree, quarter, year) -
      dep - amor
  end

  def yoy_operating_profit_delta(quarter, year)
    prev, cur = operating_profit(tree, quarter, year-1), operating_profit(tree, quarter, year)
    {absolute: (cur - prev), percent: ((cur - prev).to_f / prev) }
  end

  def ebitda(tree, quarter, year)
    eb = operating_profit(tree, quarter, year)
    dep = sanitize(tree, "Depreciation", year, quarter)
    amor = sanitize(tree, "Amortization", year, quarter)

    eb + dep + amor
  end

  def yoy_ebitda_delta(quarter, year)
    prev, cur = ebitda(tree, quarter, year-1), ebitda(tree, quarter, year)
    {absolute: (cur - prev), percent: ((cur - prev).to_f / prev) }
  end

  def net_income(tree, quarter, year)
    net = operating_profit(tree, quarter, year)
    net -= sanitize(tree, "Tax Expense", year, quarter)
    net -= sanitize(tree, "Interest Expense", year, quarter)
    net
  end

  def yoy_net_income_delta(quarter, year)
    prev, cur = net_income(quarter, year-1), net_income(quarter, year)
    {absolute: (cur - prev), percent: ((cur - prev).to_f / prev) }
  end

  def eps(tree, quarter, year)
    earn = net_income(tree, quarter, year)
    commons = sanitize(tree, "Common Shares", year, quarter)
    treasuries = sanitize(tree, "Treasury Shares", year, quarter)
    preferreds = sanitize(tree, "Preferred Shares", year, quarter)
    shares = commons + preferreds + treasuries

    return 0 if shares == 0
    earn / shares
  end

  def yoy_eps_delta(tree, quarter, year)
    cur, prev = eps(tree, quarter, year), eps(tree, quarter, year-1)
    {absolute: (cur - prev), percent: ((cur-prev).to_f / prev)}
  end

  def opex(tree, quarter, year)
    sga = sanitize(tree, "SG&A Expense", year, quarter)
    rd = sanitize(tree, "Research & Development", year, quarter)
    sga + rd
  end

  def gross_margin(tree, quarter, year)
    sales = sanitize(tree, "Revenue", year, quarter)
    return 0 unless sales
    gross_profit(tree, quarter, year) / sales
  end

  def operating_margin(tree, quarter, year)
    sales = sanitize(tree, "Revenue", year, quarter)
    return 0 unless sales
    operating_profit(tree, quarter, year) / sales
  end

  def ebitda_margin(tree, quarter, year)
    sales = sanitize(tree, "Revenue", year, quarter)
    return 0 if sales == 0
    ebitda(tree, quarter, year) / sales
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

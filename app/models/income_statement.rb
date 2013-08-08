class IncomeStatement < ActiveRecord::Base
  attr_accessible :company_id, :metrics_attributes

  belongs_to :company
  has_many :metrics, as: :statementable
  accepts_nested_attributes_for :metrics, reject_if: proc { |att| att['value'].blank? }

  def gross_profit(quarter, year)
    results = Metric.where(statementable_id: id, year: year, quarter: quarter,
                            name:["revs", "cogs"])
    revs = results.find { |e| e.name == "revs" }
    cor = results.find { |e| e.name == "cogs" }
    revs.value.to_f - cor.value.to_f
  end

  def yoy_gross_profit_delta(quarter, year)
    prev, cur = gross_profit(quarter, year-1), gross_profit(quarter, year)
    {absolute: (cur - prev), percent: ((cur - prev).to_f / prev) }
  end

  def operating_profit(quarter, year)
    cf_id = company.cashflow.id
    b_id = company.balance.id
    cogs = Metric.where(statementable_id: id, quarter: quarter, year: year,
                          name: "cogs").first.value
    dep = Metric.where(statementable_id: cf_id, quarter: quarter, year: year,
                          name: "depreciation").first.value
    amor = Metric.where(statementable_id: b_id, quarter: quarter, year: year,
                          name: "amortization").first.value
    gross_profit(quarter, year).to_f - opex(quarter, year).to_f -
      cogs - dep - amor
  end

  def yoy_operating_profit_delta(quarter, year)
    prev, cur = operating_profit(quarter, year-1), operating_profit(quarter, year)
    {absolute: (cur - prev), percent: ((cur - prev).to_f / prev) }
  end

  def ebitda(quarter, year)
    eb = operating_profit(quarter, year)
    cf_id = company.cashflow.id
    b_id = company.balance.id
    dep = Metric.where(statementable_id: cf_id, quarter: quarter, year: year,
                          name: "depreciation").first.value
    amor = Metric.where(statementable_id: b_id, quarter: quarter, year: year,
                          name: "amortization").first.value
    eb + dep + amor
  end

  def yoy_ebitda_delta(quarter, year)
    prev, cur = ebitda(quarter, year-1), ebitda(quarter, year)
    {absolute: (cur - prev), percent: ((cur - prev).to_f / prev) }
  end

  def net_income(quarter, year)
    net = operating_profit(quarter, year).to_f
    logist = Metric.where(statementable_id: id, year: year, quarter: quarter, name: ["tax", "interest"])
    logist.each{|el| net -= el.value}
    net
  end

  def yoy_net_income_delta(quarter, year)
    prev, cur = net_income(quarter, year-1), net_income(quarter, year)
    {absolute: (cur - prev), percent: ((cur - prev).to_f / prev) }
  end

  def eps(quarter, year)
    earn = net_income(quarter, year)
    query = <<-SQL
              SELECT SUM(m.value) as value
              FROM companies c
              JOIN balance_sheets b
              ON c.id = b.company_id
              JOIN metrics m
              ON b.id = m.statementable_id
              WHERE c.id = "#{company.id}"
              AND year = "#{year}"
              AND quarter = "#{quarter}"
              AND m.name IN ("treasury_quantity", "common_quantity", "preferred_quantity")
              GROUP BY m.name
              SQL
    shares = ActiveRecord::Base.connection.execute(query).first
    earn / shares['value']
  end

  def yoy_eps_delta(quarter, year)
    cur, prev = eps(quarter, year), eps(quarter, year-1)
    {absolute: (cur - prev), percent: ((cur-prev).to_f / prev)}
  end

  def opex(quarter, year)
    Metric.where(statementable_id: id, year: year, quarter: quarter,
                        name: ["sga", "rd"]).
                        map(&:value).inject(:+)
  end

  def gross_margin(quarter, year)
    sales = Metric.where(statementable_id: id, year: year, quarter: quarter,
                        name: "revs").first.value
    gross_profit(quarter, year) / sales
  end

  def operating_margin(quarter, year)
    sales = Metric.where(statementable_id: id, year: year, quarter: quarter,
                        name: "revs").first.value
    operating_profit(quarter, year) / sales
  end

  def ebitda_margin(quarter, year)
    sales = Metric.where(statementable_id: id, year: year, quarter: quarter,
                        name: "revs").first.value
    ebitda(quarter, year) / sales
  end

  def build_metas
    stats = []
    operations = []
    list = metrics
    @@operations_list.each do |op|
      # operations << op if @@income_assumptions.has_key
    end

  end
  @@operations_list = [:gross_profit, :operating_profit, :ebitda, :net_income,
        :eps, :opex, :gross_margin, :operating_margin, :ebitda_margin]

  @@income_assumptions = {revs:"Revenue", gross_profit: "Gross Profit",
    gross_margin: "Gross Margin", operating_profit: "Operating Profit",
    operating_margin: "Operating Margin", ebitda: "EBITDA",
    ebitda_margin: "EBITDA Margin", net_income: "Net Income", eps: "EPS",
    cogs: "Cost of Goods Sold", opex: "Operating Expenses",
    sga: "SG&A Expense", tax: "Tax Expense",
    rd: "Research & Development"}
end

class CashFlow < ActiveRecord::Base
  attr_accessible :company_id, :metrics, :metrics_attributes

  belongs_to :company
  has_many :metrics, as: :statementable
  accepts_nested_attributes_for :metrics, reject_if: proc { |att| att['value'].blank? }

  def operating_cash_flow(quarter, year)
    i = company.income.id
    ebitda = i.ebitda(quarter, year)
    b = company.balance
    working_delta = b.working_capital(quarter, year) - b.working_capital(quarter, year - 1)
    ebitda - working_delta
  end

  def free_cash_flow(quarter, year)
    operating_cash_flow(quarter, year) - capex(quarter, year)
  end

  def free_cash_per_share(quarter, year)
    b_id = company.balance.id
    shares = Metric.where(statementable_id: b_id, quarter: quarter, year: year,
                          name: ["common_quantity", "treasury_quantity", "preferred"]).
                          map(&:value).inject(:+)
    free_cash_flow(quarter, year).to_f / shares
  end

  def delta_receivables(quarter, year)
    b_id = company.balance.id
    results = Metric.where(statementable_id: b_id, quarter: quarter,
                           year: [year, year - 1], name: "receivables").
                           sort{ |a,b| a.year <=> b.year}
    results[1] - results[0]
  end

  def delta_inventory(quarter, year)
    b_id = company.balance.id
    results = Metric.where(statementable_id: b_id, quarter: quarter,
                           year: [year, year - 1], name: "inventory").
                           sort{ |a,b| a.year <=> b.year}
    results[1] - results[0]
  end

  def delta_liabilities(quarter, year)
    b_id = company.balance.id
    results = Metric.where(statementable_id: b_id, quarter: quarter,
                           year: [year, year - 1],
                           name: ["std", "ltd", "payables"]).
                           sort{ |a,b| a.year <=> b.year}
    results[1] - results[0]
  end

  def capex(quarter, year)
    b_id = company.balance.id
    results = Metric.where(statementable_id: b_id, quarter: quarter,
                           year: [year, year - 1], name: "ppe").
                           sort{ |a,b| a.year <=> b.year}
    results[1] - results[0]
  end
end

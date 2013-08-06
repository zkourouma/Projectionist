class IncomeStatement < ActiveRecord::Base
  attr_accessible :company_id, :metrics_attributes

  belongs_to :company
  has_many :metrics, as: :statementable
  accepts_nested_attributes_for :metrics, reject_if: proc { |att| att['value'].blank? }

  def gross_profit(quarter, year)
    results = Metric.where("statementable_id = #{id} and year = #{year} and quarter = #{quarter}").
                  where(name:["revs", "cogs"])
    revs = results.find { |e| e.name == "revs" }
    cor = results.find { |e| e.name == "cogs" }
    revs.value.to_f - cor.value.to_f
  end

  def yoy_gross_profit_delta(quarter, year)
    results = Metric.where("statementable_id = #{id} and quarter = #{quarter}").
                  where(name:["revs", "cogs"]).where(year: [year, year-1])
    revs = results.select { |e| e.name == "revs" }.sort{ |a,b| a.year <=> b.year}
    cogs = results.select { |e| e.name == "cogs" }.sort{ |a,b| a.year <=> b.year}
    gp = {absolute: (revs[1].value - cogs[1].value) - (revs[0].value - cogs[0].value)}
    gp[:percent] = (gp[:absolute].to_f/(revs[0].value - cogs[0].value).to_f)
    gp
  end

  def operating_profit(quarter, year)
    gross = gross_profit(quarter, year).to_f
    opex = Metric.where(statementable_id: id, year: year, quarter: quarter, name: ["sga", "rd"])
    opex.each{ |el| gross -= el.value}
    gross
  end

  def yoy_operating_profit_delta(quarter, year)
    gross = [gross_profit(quarter, year-1).to_f, gross_profit(quarter, year).to_f]
    opex = Metric.where(statementable_id: id, quarter: quarter, name: ["sga", "rd"]).
                  where(year: [year, year-1]).sort{ |a,b| a.year <=> b.year}
    curr_ex = opex.select{|el| el.year == year}.map(&:value).inject(:+)
    prev_ex = opex.select{|el| el.year == year - 1}.map(&:value).inject(:+)
    op = {absolute: (gross[1] - curr_ex) - (gross[0] - prev_ex)}
    op[:percent] = (op[:absolute].to_f/(gross[0] - prev_ex).to_f)
    op
  end

  def net_income(quarter, year)
    net = operating_profit(quarter, year).to_f
    logist = Metric.where(statementable_id: id, year: year, quarter: quarter, name: ["tax", "interest", "depreciation", "amortization"])
    logist.each{|el| net -= el.value}
    net
  end

  def yoy_net_income_delta(quarter, year)
    op = [operating_profit(quarter, year-1), operating_profit(quarter, year)]
    logist = Metric.where(statementable_id: id, quarter: quarter, name: ["tax", "interest", "depreciation", "amortization"]).
                  where(year: [year, year-1]).sort{ |a,b| a.year <=> b.year}
    curr_ex = logist.select{|el| el.year == year}.map(&:value).inject(:+)
    prev_ex = logist.select{|el| el.year == year - 1}.map(&:value).inject(:+)
    net = {absolute: (op[1] - curr_ex) - (op[0] - prev_ex)}
    net[:percent] = (net[:absolute].to_f/(op[0] - prev_ex).to_f)
    net
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
              AND m.name IN ("treasury", "common", "preferred")
              GROUP BY m.name
              SQL
    shares = ActiveRecord::Base.connection.execute(query).first
    earn / shares['value']
  end

  def yoy_eps_delta(quarter, year)
    cur, prev = eps(quarter, year), eps(quarter, year-1)
    {absolute: (cur - prev), percent: ((cur-prev)/prev)}
  end
end

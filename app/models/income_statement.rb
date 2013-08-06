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
    revs.value - cor.value
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
    gross = gross_profit(quarter, year)
    opex = Metric.where(statementable_id: id, year: year, quarter: quarter, name: ["sga", "rd"])
    opex.each{ |el| gross -= el.value}
    gross
  end

  def yoy_operating_profit_delta(quarter, year)
    gross = [gross_profit(quarter, year-1), gross_profit(quarter, year)]
    p gross
    opex = Metric.where(statementable_id: id, quarter: quarter, name: ["sga", "rd"]).
                  where(year: [year, year-1]).sort{ |a,b| a.year <=> b.year}
    curr_ex = opex.select{|el| el.year == year}.map(&:value).inject(:+)
    p curr_ex
    prev_ex = opex.select{|el| el.year == year - 1}.map(&:value).inject(:+)
    p prev_ex
    op = {absolute: (gross[1] - curr_ex) - (gross[0] - prev_ex)}
    p op
    op[:percent] = (op[:absolute].to_f/(gross[0] - prev_ex).to_f)
    op
  end

  def net_income(quarter, year)
    # revs - cogs - depreciation/amortization - interest - sga
  end

  def yoy_net_income_delta(quarter, year)
    
  end

  def eps(quarter, year)
    
  end

  def yoy_eps_delta(quarter, year)
    
  end

  def ebitda(quarter, year)
    
  end

  def yoy_ebitda_delta(quarter, year)
    
  end
end

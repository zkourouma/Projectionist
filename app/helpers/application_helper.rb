module ApplicationHelper
  def new_quarter
    @month = Date.today.strftime('%m').to_i
    @quarters = [[4], [3], [2], [1]]

    if @month <= 3
      @quarters.rotate!(3)
      @quarters.map! do |e|
        if e == [1]
          e << Date.today.strftime('%Y').to_i
        else
          e << Date.today.strftime('%Y').to_i - 1
        end
      end
      @quarters.unshift(([2, Date.today.strftime('%Y').to_i]))
    elsif (3 < @month && @month <=6)
      @quarters.rotate!(2)
      @quarters.map! do |e|
        if e == [2] || e == [3]
          e << Date.today.strftime('%Y').to_i
        else
          e << (Date.today.strftime('%Y').to_i - 1)
        end
      end
      @quarters.unshift(([3, Date.today.strftime('%Y').to_i]))
    elsif (6 < @month && @month <= 9)
      @quarters.rotate!
      @quarters.map! do |e|
        if e != [4]
          e << Date.today.strftime('%Y').to_i
        else
          e << (Date.today.strftime('%Y').to_i - 1)
        end
      end
      @quarters.unshift(([4, Date.today.strftime('%Y').to_i]))
    elsif 9 < @month
      @quarters.map!{|e| e << Date.today.strftime('%Y').to_i}
      @quarters.unshift(([1, Date.today.strftime('%Y').to_i + 1]))
    end
  end

  def get_metric_val(statementable_id, metric_name, year, quarter)
    Metric.where(statementable_id: statementable_id, name: metric_name,
                  quarter: quarter, year: year).first.value
  end

  def build_metric_tree(company)
    ids = [company.income, company.balance, company.cashflow]
    list = Metric.where(statementable_id: ids)
    results = Hash.new do |hash, key|
      hash[key] = Hash.new do |hash, key|
        hash[key] = Hash.new
      end
    end
    list.each do |metric|
      results[metric.display_name][metric.year][metric.quarter] = metric
    end
    results
  end

  def forecast(metric_tree, assumptions)
    results = Hash.new do |hash, key|
      hash[key] = Hash.new do |hash, key|
        hash[key] = Hash.new
      end
    end

    metric_tree.each do |metric, years|
      ass = assumptions.select{|e| e.name == metric}
      ending = Date.today.strftime('%Y').to_i
      ending -= 1 unless years[ending]
      start = ending - 1
      if !ass.empty?
        results[metric] = assumed(ass, years[start], years[ending])
      elsif years.length == 1
        results[metric] = single_year(years.first[0], years)
      else
        results[metric] = year_over_year(years[start], years[ending])
      end
    end
    results
  end

  def assumed(assumptions, year_one, year_two)
    results = Hash.new do |hash, key|
      hash[key] = Hash.new
    end
    era = year_two.first.last.year + 1
    stat_id = year_one.first.last.statementable_id
    stat_type = year_one.first.last.statementable_type
    nombre = year_one.first.last.name
    year_two.merge!(assumed_filler(assumptions, year_one, year_two)){|key, v1, v2| v1 } if year_two.length < 4
    4.times do |i|
      multiplier = growth_assumption(assumptions)
      if multiplier
        if multiplier.time_unit == 'y'
          new_val = year_two[i+1].value * (1 + multiplier.value)
        elsif i < 1
          new_val = year_two[4].value * (1 + multiplier.value)
        else
          new_val = results[era][i].value * (1 + multiplier.value)
        end
      else
        level = assumptions.find{|e| e.assumption_type == "run_rate"}
        if level.time_unit == 'y'
          new_val = level.value/4
        else
          new_val = level.value
        end
      end
      results[era][i+1] = Metric.new(statementable_id: stat_id, statementable_type: stat_type,
                          year: era, quarter: (i + 1), value: new_val,
                          name: nombre, forward: true)
    end
    results
  end

  def single_year(year, quarters)
    results = Hash.new do |hash, key|
      hash[key] = Hash.new
    end
    quarters.each do |quarter, metric|
        results[year + 1][quarter] = Metric.
            new(statementable_id: metric.statementable_id, statementable_type: metric.statementable_type,
            year: year + 1, quarter: quarter, name: metric.name, value: metric.value, forward: true)
    end
    results
  end

  def year_over_year(year_one, year_two)
    results = Hash.new do |hash, key|
      hash[key] = Hash.new
    end
    era = year_two.first.last.year + 1
    stat_id = year_one.first.last.statementable_id
    stat_type = year_one.first.last.statementable_type
    nombre = year_one.first.last.name
    year_two.merge!(filler(year_one, year_two)){|key, v1, v2| v1 } if year_two.length < 4
    year_two.each do |quarter, metric|
      if year_one[quarter]
        diff = (metric.value - year_one[quarter].value)/year_one[quarter].value
      else
        diff = 0
      end
      new_val = metric.value * (1 + diff)
      new_met = Metric.new(statementable_id: stat_id, statementable_type: stat_type,
                        year: era, quarter: quarter, value: new_val,
                        name: nombre, forward: true)
      results[era][quarter] = new_met
    end
    results
  end

  def assumed_filler(assumptions, year_one, year_two)
    results = Hash.new
    era = year_two.first.last.year
    stat_id = year_two.first.last.statementable_id
    stat_type = year_two.first.last.statementable_type
    nombre = year_two.first.last.name
    4.times do |i|
      next if (year_two[i+1] || results[i+1])
      multiplier = growth_assumption(assumptions)
      if multiplier
        if multiplier.time_unit == 'y'
          new_val = year_one[i+1].value * (1 + multiplier.value)
        elsif i < 1
          new_val = year_one[4].value * (1 + multiplier.value)
        else
          new_val = year_two[i].value * (1 + multiplier.value)
        end
      else
        level = assumptions.find{|e| e.assumption_type == "run_rate"}
        if level.time_unit == 'y'
          new_val = level.value/4
        else
          new_val = level.value
        end
      end
      results[i+1] = Metric.new(statementable_id: stat_id, statementable_type: stat_type,
                          year: era, quarter: (i + 1), value: new_val,
                          name: nombre, forward: true)
    end
    results
  end

  def filler(year_one, year_two)
    results = Hash.new
    era = year_two.first.last.year
    stat_id = year_two.first.last.statementable_id
    stat_type = year_two.first.last.statementable_type
    nombre = year_two.first.last.name
    avg = 0
    year_one.each do |quarter, metric| 
      next unless year_two[quarter]
      avg += (year_two[quarter].value - metric.value)/metric.value
    end
    avg = [avg/year_one.length, 5].min
    4.times do |i|
      next if year_two[i + 1]
      if year_one[i+1]
        new_val = year_one[i+1].value * (1 +  avg)
      else
        new_val = year_one.first.last.value
      end
      results[i + 1] = Metric.new(statementable_id: stat_id, statementable_type: stat_type,
                          year: era, quarter: (i + 1), value: new_val,
                          name: nombre, forward: true)
    end
    results
  end

  def growth_assumption(assumptions)
    assumptions.find{|e| e.assumption_type == "growth"}
  end

  def annual_metric_val(statementable_id, metric_name, year, quarter=1)

  end
end

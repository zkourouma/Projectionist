module ApplicationHelper
  def new_quarter
#   Generates the present fiscal quarter with the four previous quarters
#   The implicit year will be the fiscal year based on the present time
#   Assuming fiscal year end in September
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

  def build_metric_tree(company)
#   Hash tree with all the metrics associated with a company
    ids = [company.income.id, company.balance.id, company.cashflow.id]
    income = Metric.where(statementable_id: ids[0], statementable_type: 'IncomeStatement')
    balance = Metric.where(statementable_id: ids[1], statementable_type: 'BalanceSheet')
    cashflow = Metric.where(statementable_id: ids[2], statementable_type: 'CashFlow')
    
    list = income + balance + cashflow
    
    results = Hash.new do |hash, key|
      hash[key] = Hash.new do |hash, key|
        hash[key] = Hash.new
      end
    end
    list.each do |metric|
#     Basic structure of the tree to access a specific metric
      results[metric.display_name][metric.year][metric.quarter] = metric
    end
    results
  end

  def forecast(metric_tree, assumptions)
#   Creates metric objects for the next four quarters
    results = Hash.new do |hash, key|
      hash[key] = Hash.new do |hash, key|
        hash[key] = Hash.new
      end
    end

    metric_tree.each do |metric, years|
      ass = assumptions.select{|e| e.name == metric}
      ending = Date.today.strftime('%Y').to_i
      until years[ending]
        ending -= 1
      end
      start = ending - 1
      if !ass.empty?
#       If there are any relevant assumptions for the metric
        results[metric] = assumed(ass, years[start], years[ending])
      elsif years.length == 1
        results[metric] = single_year(years.first[0], years.first[1])
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
#   Details for the estimated metrics
    era = year_two.first.last.year + 1
    stat_id = year_two.first.last.statementable_id
    stat_type = year_two.first.last.statementable_type
    nombre = year_two.first.last.name
    
    year_two.merge!(assumed_filler(assumptions, year_one, year_two)){|key, v1, v2| v1 } if year_two.length < 4
    
    4.times do |i|
      multiplier = growth_assumption(assumptions)
      if multiplier
        if multiplier.time_unit == 'y' && year_two[i+1]
#         If the assumption is growth AND year over year AND there is a value
#         to build off of (as a base)
          new_val = year_two[i+1].value * (1 + multiplier.value)
        elsif i < 1 && year_two[4]
#         If it is growth AND quarter over quarter, BUT the current
#         'quarter' is Q1 AND there is a value for Q4 of the prior year
          new_val = year_two[4].value * (1 + multiplier.value)
        elsif results[era][i]
#         If it growth AND quarter over quarter AND it is after Q1 AND
#         there is a value for the prior quarter
          new_val = results[era][i].value * (1 + multiplier.value)
        else
#         Worst case scenario, just average the levels for the present year
          new_val = some_average(year_two)
        end
      else
#       If there is a run rate assumption
        level = assumptions.find{|e| e.assumption_type == "run_rate"}
        if level.time_unit == 'y'
#         Average a yearly run rate
          new_val = level.value/4
        else
#         Quarterly run rate
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

#   Details for the estimated metrics
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
#   Fills in the present year based on the assumptions of the metric
#   This is called for the remaining quarters for the current year
    results = Hash.new
#   Details for the estimated metric
    era = year_two.first.last.year
    stat_id = year_two.first.last.statementable_id
    stat_type = year_two.first.last.statementable_type
    nombre = year_two.first.last.name
    
    4.times do |i|
#     If the quarter we're looking at already has a metric, there's no
#     need to create extra data
      next if (year_two[i+1] || results[i+1])

      multiplier = growth_assumption(assumptions)
      if multiplier
        if multiplier.time_unit == 'y' && year_one[i+1]
#         if the assumption is growth AND year over year AND there is a value
#         to build off of (as a base)
          new_val = year_one[i+1].value * (1 + multiplier.value)
        elsif i < 1 && year_one[4]
#         If it is growth AND quarter over quarter, BUT the current
#         'quarter' is Q1 AND there is a value for Q4 of the prior year
          new_val = year_one[4].value * (1 + multiplier.value)
        elsif year_two[i]
#         If it growth AND quarter over quarter AND it is after Q1 AND
#         there is a value for the prior quarter
          new_val = year_two[i].value * (1 + multiplier.value)
        else
#         Worst case scenario, just average the levels for the present year
          new_val = some_average(year_two)
        end
      else
#       If there is a run rate assumption
        level = assumptions.find{|e| e.assumption_type == "run_rate"}
        if level.time_unit == 'y'
#         Average a yearly run rate
          new_val = level.value/4
        else
#         Quarterly run rate
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
#   This is called to fill in remaining quarters for the current fiscal year
    results = Hash.new
#   Details for the estimated metrics
    era = year_two.first.last.year
    stat_id = year_two.first.last.statementable_id
    stat_type = year_two.first.last.statementable_type
    nombre = year_two.first.last.name
    avg = 0
    
    year_one.each do |quarter, metric| 
      next unless year_two[quarter]
      next if metric.value == 0
      avg += (year_two[quarter].value - metric.value)/metric.value
    end
#   Take the min of the average or five in case there are 'infite' growth for
#   some quarters. Meaning the year over year comparison is coming off a base
#   that is less than zero
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

  def charter(metric_tree, relevance, time)
#   'charter' was made to convert the data structure of my hash tree into an 
#   array of arrays that can be converted to JS and read by the API
#   Here, 'relevance' is a hash of metrics that are relevant to the statement
#   that the chart is being generated for
    depth = 0
    footers = Hash.new{|hash, key| hash[key] = Array.new}
    
    metric_tree.each do |name, years|
      next unless relevance.has_value?(name)
      years.each do |year, quarters| 
        quarters.each do |quarter, metric|
          unless footers[year].include?(quarter)
            footers[year] << quarter
            depth += 1
          end
        end
      end
    end
    
    predata = Hash.new{|hash, key| hash[key] = Array.new}
    
    metric_tree.each do |name, years|
      next unless relevance.has_value?(name)
#     The labels for the chart, the first array in the data structure
      predata["labels"] << ['number', name]
      predata["labels"] << ['boolean', 'certainty']
      time.each do |pair|
        if years[pair[1]][pair[0]]
          predata["#{pair[1]}Q#{pair[0]}"] << years[pair[1]][pair[0]].value
#         !forward determines whether it's a 'certain' metric
          predata["#{pair[1]}Q#{pair[0]}"] << !years[pair[1]][pair[0]].forward
        else
          predata["#{pair[1]}Q#{pair[0]}"] << 0
          predata["#{pair[1]}Q#{pair[0]}"] << false
        end
      end
    end

    postdata = Array.new
    predata.each do |label, datum|
      next if label == "labels"
      postdata << ([label] + datum)
    end

    postdata.sort!{|x,y| x.first <=> y.first }
    postdata.unshift(predata['labels'])
    postdata
  end

  def growth_assumption(assumptions)
#   Returns either the growth assumption for the metric or nil
    assumptions.find{|e| e.assumption_type == "growth"}
  end

  def complete_statement?(tree, year, quarter, relevance)
    relevance.each do |metric_name, name|
      return false unless tree[name][year][quarter]
    end
    true
  end

  def some_average(year)
    avg, counter = 0, 0
    year.each{|q, m| avg+= m.value; counter += 1}
    avg / counter
  end

  def remove_dup(metric, metric_tree)
    name, year, quarter = metric.display_name, metric.year, metric.quarter
    p name
    if metric_tree[name][year][quarter]
      met = Metric.where(name: metric.name, year: year, quarter: quarter,
                statementable_type: metric.statementable_type,
                statementable_id: metric.statementable_id)[0]
      p met 
      met.destroy
    end
  end
end

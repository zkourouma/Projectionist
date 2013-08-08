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
    elsif (3 < @month && @month <=6)
      @quarters.rotate!(2)
      @quarters.map! do |e|
        if e == [2] || e == [3]
          e << Date.today.strftime('%Y').to_i
        else
          e << (Date.today.strftime('%Y').to_i - 1)
        end
      end
    elsif (6 < @month && @month <= 9)
      @quarters.rotate!
      @quarters.map! do |e|
        if e != [4]
          e << Date.today.strftime('%Y').to_i
        else
          e << (Date.today.strftime('%Y').to_i - 1)
        end
      end
    elsif 9 < @month
      @quarters.map!{|e| e << Date.today.strftime('%Y').to_i}
    end
  end

  def get_metric_val(statementable_id, metric_name, year, quarter)
    Metric.where(statementable_id: statementable_id, name: metric_name,
                  quarter: quarter, year: year).first.value
  end

  def build_metric_tree(statement)
    list = Metric.where(statementable_id: statement.id, statementable_type: statement.class)
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

  def annual_metric_val(statementable_id, metric_name, year, quarter=1)

  end
end

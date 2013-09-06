class Project < ActiveRecord::Base
  attr_accessible :name, :charts, :metrics, :company_id, :user_id,
                  :metrics_attributes, :assumptions_attributes

  belongs_to :company
  belongs_to :user
  has_many :assumptions
  accepts_nested_attributes_for :assumptions, reject_if: proc { |att| att['value'].blank? }
  has_many :metrics, as: :statementable
  accepts_nested_attributes_for :metrics, reject_if: proc { |att| att['value'].blank? }

  
  def project_impact(metrics, metric_tree)
    impact = Hash.new
    yr = Date.today.strftime("%Y").to_i

    metrics.each do |metric|
#     Is there a comparison metric for impact?
      if metric_tree[metric.display_name]
#       Find the most recent year
        until metric_tree[metric.display_name][yr]
          yr -= 1
        end
#       Find the most recent quarter
        quarter = 4
        until metric_tree[metric.display_name][yr][quarter]
          quarter -= 1
        end

        current_metric = metric_tree[metric.display_name][yr][quarter]
        percent_change = (current_metric.value - metric.value)/current_metric.value
        impact[metric.display_name] = percent_change.round(4)*100
        operation_impacts(metric_tree, metric, yr, quarter, impact)
      end
    end
    impact
  end

  def operation_impact(metric_tree, metric, yr, quarter, impact_hash)
    op_list = find_operations(metric)
    op_list.each do |operation, display_name|
        statements.each do |statement|
          if statement.respond_to?(operation)
            impact_hash[display_name] = get_impact(metric_tree, metric, operation, statement, yr, quarter)
        end  
    end
  end

  def get_impact(metric_tree, metric, operation, statement, yr, quarter)
    pre_proj = statement.send(operation, [metric_tree, quarter, yr, metric])
  end

  def find_operations(metric)
    ops = []

    implicated.each do |statement, metrics|
      ops + get_operations(metric, statement) if metrics.values.include?(metric.name)
    end
    
    ops
  end

  def get_operations(metric, statement)
    statement.operations[metric.display_name]
  end

  def implicated
    @implicated_operations
  end

  def statements
    @statements
  end

  @implicated_operations = {IncomeStatement: IncomeStatement.relevant,
                      BalanceSheet: BalanceSheet.relevant,
                      CashFlow: CashFlow.relevant}

  @statements = [IncomeStatement, BalanceSheet, CashFlow]
end

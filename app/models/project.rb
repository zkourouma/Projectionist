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
        percent_change = ((current_metric.value - metric.value).abs)/current_metric.value
        impact[metric.display_name] = percent_change.round(4)*100
      end
    end
    impact
  end
end

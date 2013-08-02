class BalanceSheet < ActiveRecord::Base
  attr_accessible :company_id, :metric_attributes

  belongs_to :company
  has_many :metrics
  accepts_nested_attributes_for :metric_attributes
end

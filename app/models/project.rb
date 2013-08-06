class Project < ActiveRecord::Base
  attr_accessible :name, :charts, :metrics, :company_id, :user_id, :metrics_attributes

  belongs_to :company
  belongs_to :user
  has_many :metrics
  accepts_nested_attributes_for :metrics, reject_if: proc { |att| att['value'].blank? }
end

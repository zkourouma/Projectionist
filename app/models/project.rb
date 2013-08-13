class Project < ActiveRecord::Base
  attr_accessible :name, :charts, :metrics, :company_id, :user_id,
                  :metrics_attributes, :assumptions_attributes

  belongs_to :company
  belongs_to :user
  has_many :assumptions
  accepts_nested_attributes_for :assumptions, reject_if: proc { |att| att['value'].blank? }
  has_many :metrics, as: :statementable
  accepts_nested_attributes_for :metrics, reject_if: proc { |att| att['value'].blank? }
end

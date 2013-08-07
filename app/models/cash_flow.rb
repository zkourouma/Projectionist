class CashFlow < ActiveRecord::Base
  attr_accessible :company_id, :metrics, :metrics_attributes

  belongs_to :company
  has_many :metrics, as: :statementable
  accepts_nested_attributes_for :metrics, reject_if: proc { |att| att['value'].blank? }

  def operating_cash_flow(quarter, year)

  end

  def free_cash_flow(quarter, year)

  end

  def free_cash_per_share(quarter, year)

  end
end

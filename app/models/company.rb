class Company < ActiveRecord::Base
  attr_accessible :employees, :headquarters, :industry, :name, :user_id,
                   :industry_id, :assumptions_attributes, :company_industries_attributes

  belongs_to :user
  has_many :projects
  has_many :assumptions
  has_many :company_industries
  has_many :industries, through: :company_industries
  has_one :income, class_name: 'IncomeStatement'
  has_one :balance, class_name: 'BalanceSheet'
  has_one :cashflow, class_name: 'CashFlow'
  accepts_nested_attributes_for :company_industries, reject_if: proc { |att| att['industry_id'].blank? }
  accepts_nested_attributes_for :assumptions, reject_if: proc { |att| att['metric_name'].blank? }
end

class Company < ActiveRecord::Base
  attr_accessible :employees, :headquarters, :industry, :name, :user_id

  belongs_to :user
  has_many :projects
  has_one :income, class_name: 'IncomeStatement'
  has_one :balance, class_name: 'BalanceSheet'
  has_one :cashflow, class_name: 'CashFlow'
end

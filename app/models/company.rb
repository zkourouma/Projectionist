class Company < ActiveRecord::Base
  attr_accessible :employees, :headquarters, :industry, :name, :user_id

  belongs_to :user
  has_many :statements, :class_name => ["Income Statement", "Balance Sheet", "Cash Flow"]
end

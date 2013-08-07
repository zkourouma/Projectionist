class Industry < ActiveRecord::Base
  attr_accessible :name

  has_many :company_industries
  has_many :companies, through: :company_industries
end

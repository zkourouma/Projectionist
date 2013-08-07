class CompanyIndustry < ActiveRecord::Base
  attr_accessible :company_id, :industry_id

  belongs_to :company
  belongs_to :industry
end

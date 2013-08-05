class Project < ActiveRecord::Base
  attr_accessible :name, :charts, :metrics, :company_id, :user_id

  belongs_to :company
  belongs_to :user
end

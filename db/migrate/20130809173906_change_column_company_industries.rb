class ChangeColumnCompanyIndustries < ActiveRecord::Migration
  def change
    change_column :company_industries, :company_id, :integer
    change_column :company_industries, :industry_id, :integer
  end
end

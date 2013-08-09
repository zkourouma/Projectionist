class DropColumnCompaniesIndustries < ActiveRecord::Migration
  def change
    remove_column :company_industries, :company_id
    remove_column :company_industries, :industry_id
    add_column :company_industries, :company_id, :integer
    add_column :company_industries, :industry_id, :integer
  end
end

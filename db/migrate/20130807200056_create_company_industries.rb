class CreateCompanyIndustries < ActiveRecord::Migration
  def change
    create_table :company_industries do |t|
      t.string :company_id
      t.string :industry_id

      t.timestamps
    end
  end
end

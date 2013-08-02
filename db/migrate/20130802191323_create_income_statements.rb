class CreateIncomeStatements < ActiveRecord::Migration
  def change
    create_table :income_statements do |t|
      t.string :company_id

      t.timestamps
    end
  end
end

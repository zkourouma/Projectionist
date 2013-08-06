class CreateIncomeStatements < ActiveRecord::Migration
  def change
    create_table :income_statements do |t|
      t.integer :company_id
      t.integer :user_id

      t.timestamps
    end
  end
end

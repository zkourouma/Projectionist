class CreateBalanceSheets < ActiveRecord::Migration
  def change
    create_table :balance_sheets do |t|
      t.integer :company_id
      t.integer :user_id

      t.timestamps
    end
  end
end

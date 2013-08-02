class CreateBalanceSheets < ActiveRecord::Migration
  def change
    create_table :balance_sheets do |t|
      t.string :company_id

      t.timestamps
    end
  end
end

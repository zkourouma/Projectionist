class CreateCashFlows < ActiveRecord::Migration
  def change
    create_table :cash_flows do |t|
      t.integer :company_id
      t.integer :user_id

      t.timestamps
    end
  end
end

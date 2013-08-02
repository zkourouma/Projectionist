class CreateCashFlows < ActiveRecord::Migration
  def change
    create_table :cash_flows do |t|
      t.string :company_id

      t.timestamps
    end
  end
end

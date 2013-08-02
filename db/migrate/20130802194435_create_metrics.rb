class CreateMetrics < ActiveRecord::Migration
  def change
    create_table :metrics do |t|
      t.string :name
      t.string :period
      t.integer :value
      t.integer :statement_id

      t.timestamps
    end
  end
end

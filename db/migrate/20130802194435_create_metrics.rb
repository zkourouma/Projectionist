class CreateMetrics < ActiveRecord::Migration
  def change
    create_table :metrics do |t|
      t.string :name
      t.integer :quarter
      t.integer :year
      t.float :value
      t.integer :statement_id

      t.timestamps
    end
    add_index :metrics, :statement_id
  end
end

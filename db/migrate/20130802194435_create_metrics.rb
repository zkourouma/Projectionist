class CreateMetrics < ActiveRecord::Migration
  def change
    create_table :metrics do |t|
      t.string :name
      t.integer :quarter
      t.integer :year
      t.integer :value
      t.integer :statement_id

      t.timestamps
    end
  end
end

class CreateAssumptions < ActiveRecord::Migration
  def change
    create_table :assumptions do |t|
      t.integer :company_id
      t.integer :project_id
      t.integer :timespan
      t.string :time_unit
      t.string :metric_name
      t.string :assumption_type
      t.float :value

      t.timestamps
    end
  end
end

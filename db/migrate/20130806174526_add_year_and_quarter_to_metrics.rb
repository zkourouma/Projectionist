class AddYearAndQuarterToMetrics < ActiveRecord::Migration
  def change
    add_column :metrics, :year, :integer
    add_column :metrics, :quarter, :integer
    remove_column :metrics, :period
  end
end

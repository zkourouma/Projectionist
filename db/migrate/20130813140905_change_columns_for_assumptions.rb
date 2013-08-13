class ChangeColumnsForAssumptions < ActiveRecord::Migration
  def change
    remove_column :assumptions, :timespan
  end
end

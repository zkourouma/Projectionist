class AddForwardToMetrics < ActiveRecord::Migration
  def change
    add_column :metrics, :forward, :boolean, default: false
  end
end

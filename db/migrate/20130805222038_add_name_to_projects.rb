class AddNameToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :name, :string
    add_index :metrics, :statementable_id
  end
end

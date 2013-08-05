class Polymorphs < ActiveRecord::Migration
  def change
    rename_column :metrics, :statement_id, :statementable_id
    add_column :metrics, :statementable_type, :string
  end
end

class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :name
      t.string :headquarters
      t.string :industry
      t.integer :employees

      t.timestamps
    end
  end
end

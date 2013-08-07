class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string :name
      t.string :headquarters
      t.integer :employees
      t.integer :user_id

      t.timestamps
    end
  end
end

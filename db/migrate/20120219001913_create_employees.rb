class CreateEmployees < ActiveRecord::Migration
  def change
    create_table :employees do |t|
      t.integer :id
      
      t.string :first_name
      t.string :last_name
      t.string :ssn
      t.date :date_of_birth
      t.string :phone
      t.string :role
      t.boolean :active, :default => true

      t.timestamps
    end
  end
end

class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :id
      
      t.string :email
      t.string :password_digest
      t.integer :employee_id

      t.timestamps
    end
  end
end

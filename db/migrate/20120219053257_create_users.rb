class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :id
      
      t.string :email
      t.string :password_hash
      t.string :password_salt
      t.integer :employee_id

      t.timestamps
    end
  end
end

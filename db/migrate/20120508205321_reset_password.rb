class ResetPassword < ActiveRecord::Migration
  def up
    add_column :users, :reset_password_code, :string
    add_column :users, :reset_password_code_until, :datetime
  end

  def down
    remove_column :users, :reset_password_code, :string
    remove_column :users, :reset_password_code_until, :datetime
  end
end

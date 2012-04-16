class CreateStores < ActiveRecord::Migration
  def change
    create_table :stores do |t|
      t.integer :id
      
      t.string :name
      t.string :street
      t.string :city
      t.string :state
      t.string :zip
      t.string :phone
      t.float :latitude
      t.float :longitude
      t.boolean :active, :default => true

      t.timestamps
    end
  end
end

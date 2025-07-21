class CreateInventories < ActiveRecord::Migration[8.0]
  def change
    create_table :inventories do |t|
      t.references :user, null: false, foreign_key: true
      t.references :bead, null: false, foreign_key: true
      t.decimal :quantity, precision: 10, scale: 3, null: false, default: 0
      t.string :quantity_unit, null: false, default: 'unit'

      t.timestamps
    end
    
    add_index :inventories, [:user_id, :bead_id], unique: true
  end
end

class CreateUserInventorySettings < ActiveRecord::Migration[8.0]
  def change
    create_table :user_inventory_settings do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.json :field_definitions, null: false, default: []

      t.timestamps
    end
  end
end

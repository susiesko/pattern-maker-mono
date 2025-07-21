class AddUniqueConstraintToUserInventorySettings < ActiveRecord::Migration[8.0]
  def change
    # Remove the existing index and add a unique constraint
    remove_index :user_inventory_settings, :user_id if index_exists?(:user_inventory_settings, :user_id)
    add_index :user_inventory_settings, :user_id, unique: true
  end
end

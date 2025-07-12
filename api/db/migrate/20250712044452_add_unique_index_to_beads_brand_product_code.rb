class AddUniqueIndexToBeadsBrandProductCode < ActiveRecord::Migration[8.0]
  def change
    add_index :beads, :brand_product_code, unique: true
  end
end

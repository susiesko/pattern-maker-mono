class CreateBeads < ActiveRecord::Migration[8.0]
  def change
    create_table :beads do |t|
      t.string :name, null: false
      t.string :brand_product_code, null: false
      t.json :metadata
      t.references :brand, null: false, foreign_key: { to_table: :bead_brands }
      t.references :size, null: false, foreign_key: { to_table: :bead_sizes }

      t.timestamps
    end
  end
end

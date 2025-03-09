class CreateBeadSizes < ActiveRecord::Migration[8.0]
  def change
    create_table :bead_sizes do |t|
      t.string :size, null: false
      t.text :description
      t.json :metadata
      t.references :brand, null: false, foreign_key: { to_table: :bead_brands }
      t.references :type, null: false, foreign_key: { to_table: :bead_types }

      t.timestamps
    end
  end
end

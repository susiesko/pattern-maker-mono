class CreateBeadColorLinks < ActiveRecord::Migration[8.0]
  def change
    create_table :bead_color_links do |t|
      t.references :bead, null: false, foreign_key: true
      t.references :color, null: false, foreign_key: { to_table: :bead_colors }

      t.timestamps
    end

    add_index :bead_color_links, [:bead_id, :color_id], unique: true
  end
end
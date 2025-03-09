class CreateBeadFinishLinks < ActiveRecord::Migration[8.0]
  def change
    create_table :bead_finish_links do |t|
      t.references :bead, null: false, foreign_key: true
      t.references :finish, null: false, foreign_key: { to_table: :bead_finishes }

      t.timestamps
    end

    add_index :bead_finish_links, [:bead_id, :finish_id], unique: true
  end
end
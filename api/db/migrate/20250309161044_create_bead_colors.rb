class CreateBeadColors < ActiveRecord::Migration[8.0]
  def change
    create_table :bead_colors do |t|
      t.string :name, null: false
      t.text :description

      t.timestamps
    end
  end
end
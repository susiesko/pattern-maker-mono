# frozen_string_literal: true

class CreateBeadTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :bead_types do |t|
      t.string :name, null: false
      t.references :brand, null: false, foreign_key: { to_table: :bead_brands }

      t.timestamps
    end
  end
end

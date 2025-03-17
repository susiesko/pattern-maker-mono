# frozen_string_literal: true

class CreateBeadBrands < ActiveRecord::Migration[8.0]
  def change
    create_table :bead_brands do |t|
      t.string :name, null: false
      t.string :website

      t.timestamps
    end
  end
end

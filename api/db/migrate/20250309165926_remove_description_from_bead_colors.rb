# frozen_string_literal: true

class RemoveDescriptionFromBeadColors < ActiveRecord::Migration[8.0]
  def change
    remove_column :bead_colors, :description, :string
  end
end

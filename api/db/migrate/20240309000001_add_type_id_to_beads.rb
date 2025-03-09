class AddTypeIdToBeads < ActiveRecord::Migration[8.0]
  def change
    add_reference :beads, :type, foreign_key: { to_table: :bead_types }, null: true
  end
end
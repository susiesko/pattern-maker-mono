class AddNotNullConstraintToTypeIdInBeads < ActiveRecord::Migration[8.0]
  def change
    change_column_null :beads, :type_id, false
  end
end
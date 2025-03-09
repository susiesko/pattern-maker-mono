class RemoveDescriptionFromBeadSizes < ActiveRecord::Migration[8.0]
  def change
    remove_column :bead_sizes, :description, :string
  end
end

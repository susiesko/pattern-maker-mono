class RemoveDescriptionFromBeadFinishes < ActiveRecord::Migration[8.0]
  def change
    remove_column :bead_finishes, :description, :string
  end
end

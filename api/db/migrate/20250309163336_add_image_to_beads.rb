class AddImageToBeads < ActiveRecord::Migration[8.0]
  def change
    add_column :beads, :image, :string
  end
end

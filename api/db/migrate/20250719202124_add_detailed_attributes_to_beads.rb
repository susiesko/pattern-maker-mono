class AddDetailedAttributesToBeads < ActiveRecord::Migration[8.0]
  def change
    add_column :beads, :shape, :string
    add_column :beads, :size, :string
    add_column :beads, :color_group, :string
    add_column :beads, :glass_group, :string
    add_column :beads, :finish, :string
    add_column :beads, :dyed, :string
    add_column :beads, :galvanized, :string
    add_column :beads, :plating, :string
  end
end

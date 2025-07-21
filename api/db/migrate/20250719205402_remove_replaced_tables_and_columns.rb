class RemoveReplacedTablesAndColumns < ActiveRecord::Migration[8.0]
  def change
    # Step 1: Remove foreign key constraints first
    remove_foreign_key :beads, :bead_types if foreign_key_exists?(:beads, :bead_types)
    remove_foreign_key :beads, :bead_sizes if foreign_key_exists?(:beads, :bead_sizes)
    remove_foreign_key :bead_sizes, :bead_types if foreign_key_exists?(:bead_sizes, :bead_types)
    remove_foreign_key :bead_color_links, :beads if foreign_key_exists?(:bead_color_links, :beads)
    remove_foreign_key :bead_color_links, :bead_colors if foreign_key_exists?(:bead_color_links, :bead_colors)
    remove_foreign_key :bead_finish_links, :beads if foreign_key_exists?(:bead_finish_links, :beads)
    remove_foreign_key :bead_finish_links, :bead_finishes if foreign_key_exists?(:bead_finish_links, :bead_finishes)
    
    # Step 2: Remove columns from beads table that reference the tables we're dropping
    remove_column :beads, :type_id if column_exists?(:beads, :type_id)
    remove_column :beads, :size_id if column_exists?(:beads, :size_id)
    
    # Step 3: Remove join tables first (they reference the main tables)
    drop_table :bead_color_links if table_exists?(:bead_color_links)
    drop_table :bead_finish_links if table_exists?(:bead_finish_links)
    
    # Step 4: Remove the main tables that are being replaced by columns
    drop_table :bead_types if table_exists?(:bead_types)
    drop_table :bead_sizes if table_exists?(:bead_sizes)
    drop_table :bead_colors if table_exists?(:bead_colors)
    drop_table :bead_finishes if table_exists?(:bead_finishes)
  end
end

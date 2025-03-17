# frozen_string_literal: true

# Module for catalog-related models
module Catalog
  def self.table_name_prefix
    # No prefix needed as tables are already named with bead_ prefix
    ''
  end
end
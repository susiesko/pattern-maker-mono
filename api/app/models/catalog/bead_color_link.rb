# frozen_string_literal: true

module Catalog
  class BeadColorLink < ApplicationRecord
    # Set the table name explicitly to match the database
    self.table_name = 'bead_color_links'

    # Associations
    belongs_to :bead, class_name: 'Catalog::Bead', foreign_key: 'bead_id'
    belongs_to :color, class_name: 'Catalog::BeadColor', foreign_key: 'color_id'

    # Validations
    validates :bead_id, uniqueness: { scope: :color_id }
  end
end

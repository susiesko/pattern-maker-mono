# frozen_string_literal: true

module Catalog
  class BeadColor < ApplicationRecord
    # Set the table name explicitly to match the database
    self.table_name = 'bead_colors'

    # Associations
    has_many :bead_color_links, class_name: 'Catalog::BeadColorLink', dependent: :destroy,
                                inverse_of: :color
    has_many :beads, through: :bead_color_links, class_name: 'Catalog::Bead'

    # Validations
    validates :name, presence: true
  end
end

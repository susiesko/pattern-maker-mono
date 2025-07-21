# frozen_string_literal: true

module Catalog
  class BeadBrand < ApplicationRecord
    # Set the table name explicitly to match the database
    self.table_name = 'bead_brands'

    # Associations
    has_many :beads, class_name: 'Catalog::Bead', dependent: :destroy, inverse_of: :brand

    # Validations
    validates :name, presence: true
  end
end

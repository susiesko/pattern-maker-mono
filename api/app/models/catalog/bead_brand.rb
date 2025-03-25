# frozen_string_literal: true

module Catalog
  class BeadBrand < ApplicationRecord
    # Set the table name explicitly to match the database
    self.table_name = 'bead_brands'

    # Associations
    has_many :bead_types, class_name: 'Catalog::BeadType', foreign_key: 'brand_id', dependent: :destroy
    has_many :bead_sizes, class_name: 'Catalog::BeadSize', foreign_key: 'brand_id', dependent: :destroy
    has_many :beads, class_name: 'Catalog::Bead', foreign_key: 'brand_id', dependent: :destroy

    # Validations
    validates :name, presence: true
  end
end

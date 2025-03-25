# frozen_string_literal: true

module Catalog
  class BeadSize < ApplicationRecord
    # Set the table name explicitly to match the database
    self.table_name = 'bead_sizes'

    # Associations
    belongs_to :brand, class_name: 'Catalog::BeadBrand', foreign_key: 'brand_id'
    belongs_to :type, class_name: 'Catalog::BeadType', foreign_key: 'type_id'
    has_many :beads, class_name: 'Catalog::Bead', foreign_key: 'size_id', dependent: :destroy

    # Validations
    validates :size, presence: true
  end
end

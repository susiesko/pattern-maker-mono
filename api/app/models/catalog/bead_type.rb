# frozen_string_literal: true

module Catalog
  class BeadType < ApplicationRecord
    # Set the table name explicitly to match the database
    self.table_name = 'bead_types'

    # Associations
    belongs_to :brand, class_name: 'Catalog::BeadBrand'
    has_many :bead_sizes, class_name: 'Catalog::BeadSize', foreign_key: 'type_id', dependent: :destroy,
                          inverse_of: :type
    has_many :beads, class_name: 'Catalog::Bead', foreign_key: 'type_id', dependent: :destroy, inverse_of: :type

    # Validations
    validates :name, presence: true
  end
end

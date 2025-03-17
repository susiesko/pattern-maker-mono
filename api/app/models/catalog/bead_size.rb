# frozen_string_literal: true

module Catalog
  class BeadSize < ApplicationRecord
    # Associations
    belongs_to :brand, class_name: 'Catalog::BeadBrand'
    belongs_to :type, class_name: 'Catalog::BeadType'
    has_many :beads, foreign_key: :size_id, dependent: :destroy

    # Validations
    validates :size, presence: true
  end
end

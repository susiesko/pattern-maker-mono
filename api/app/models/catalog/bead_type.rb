# frozen_string_literal: true

module Catalog
  class BeadType < ApplicationRecord
    # Associations
    belongs_to :brand, class_name: 'Catalog::BeadBrand'
    has_many :bead_sizes, foreign_key: :type_id, dependent: :destroy

    # Validations
    validates :name, presence: true
  end
end

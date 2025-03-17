# frozen_string_literal: true

module Catalog
  class BeadBrand < ApplicationRecord
    # Associations
    has_many :bead_types, foreign_key: :brand_id, dependent: :destroy
    has_many :bead_sizes, foreign_key: :brand_id, dependent: :destroy
    has_many :beads, foreign_key: :brand_id, dependent: :destroy

    # Validations
    validates :name, presence: true
  end
end
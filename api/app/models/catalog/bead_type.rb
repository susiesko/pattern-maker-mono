# frozen_string_literal: true

module Catalog
  class BeadType < ApplicationRecord
    belongs_to :brand, class_name: 'Catalog::BeadBrand', foreign_key: :brand_id
    has_many :bead_sizes, foreign_key: :type_id, dependent: :destroy

    validates :name, presence: true
  end
end

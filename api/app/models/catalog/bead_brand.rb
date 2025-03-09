module Catalog
  class BeadBrand < ApplicationRecord
    has_many :bead_types, foreign_key: :brand_id, dependent: :destroy
    has_many :bead_sizes, foreign_key: :brand_id, dependent: :destroy
    has_many :beads, foreign_key: :brand_id, dependent: :destroy

    validates :name, presence: true
  end
end

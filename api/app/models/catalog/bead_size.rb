module Catalog
  class BeadSize < ApplicationRecord
    belongs_to :brand, class_name: "Catalog::BeadBrand", foreign_key: :brand_id
    belongs_to :type, class_name: "Catalog::BeadType", foreign_key: :type_id
    has_many :beads, foreign_key: :size_id, dependent: :destroy

    validates :size, presence: true
  end
end

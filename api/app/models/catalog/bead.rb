module Catalog
  class Bead < ApplicationRecord
    belongs_to :brand, class_name: "Catalog::BeadBrand", foreign_key: :brand_id
    belongs_to :type, class_name: "Catalog::BeadType", foreign_key: :type_id
    belongs_to :size, class_name: "Catalog::BeadSize", foreign_key: :size_id

    has_many :bead_color_links, dependent: :destroy
    has_many :colors, through: :bead_color_links, source: :color

    has_many :bead_finish_links, dependent: :destroy
    has_many :finishes, through: :bead_finish_links, source: :finish

    validates :name, :brand_product_code, presence: true
  end
end

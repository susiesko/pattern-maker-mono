# frozen_string_literal: true

module Catalog
  class Bead < ApplicationRecord
    # Associations
    belongs_to :brand, class_name: 'Catalog::BeadBrand'
    belongs_to :size, class_name: 'Catalog::BeadSize'
    belongs_to :type, class_name: 'Catalog::BeadType'
    has_many :bead_color_links, dependent: :destroy
    has_many :colors, through: :bead_color_links, source: :color, class_name: 'Catalog::BeadColor'
    has_many :bead_finish_links, dependent: :destroy
    has_many :finishes, through: :bead_finish_links, source: :finish, class_name: 'Catalog::BeadFinish'

    # Validations
    validates :name, presence: true
    validates :brand_product_code, presence: true
  end
end

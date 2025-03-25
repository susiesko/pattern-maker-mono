# frozen_string_literal: true

module Catalog
  class Bead < ApplicationRecord
    # Set the table name explicitly to match the database
    self.table_name = 'beads'

    # Associations
    belongs_to :brand, class_name: 'Catalog::BeadBrand', foreign_key: 'brand_id'
    belongs_to :size, class_name: 'Catalog::BeadSize', foreign_key: 'size_id'
    belongs_to :type, class_name: 'Catalog::BeadType', foreign_key: 'type_id'

    has_many :bead_color_links, class_name: 'Catalog::BeadColorLink', foreign_key: 'bead_id', dependent: :destroy
    has_many :colors, through: :bead_color_links, source: :color, class_name: 'Catalog::BeadColor'

    has_many :bead_finish_links, class_name: 'Catalog::BeadFinishLink', foreign_key: 'bead_id', dependent: :destroy
    has_many :finishes, through: :bead_finish_links, source: :finish, class_name: 'Catalog::BeadFinish'

    # Validations
    validates :name, presence: true
    validates :brand_product_code, presence: true
  end
end

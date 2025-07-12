# frozen_string_literal: true

module Catalog
  class Bead < ApplicationRecord
    # Set the table name explicitly to match the database
    self.table_name = 'beads'

    # Associations
    belongs_to :brand, class_name: 'Catalog::BeadBrand', inverse_of: :beads
    belongs_to :size, class_name: 'Catalog::BeadSize', inverse_of: :beads
    belongs_to :type, class_name: 'Catalog::BeadType', inverse_of: :beads

    has_many :bead_color_links, class_name: 'Catalog::BeadColorLink', dependent: :destroy,
                                inverse_of: :bead
    has_many :colors, through: :bead_color_links, source: :color, class_name: 'Catalog::BeadColor'

    has_many :bead_finish_links, class_name: 'Catalog::BeadFinishLink', dependent: :destroy,
                                 inverse_of: :bead
    has_many :finishes, through: :bead_finish_links, source: :finish, class_name: 'Catalog::BeadFinish'

    # Validations
    validates :name, presence: true
    validates :brand_product_code, presence: true, uniqueness: true
  end
end

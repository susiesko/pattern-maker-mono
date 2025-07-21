# frozen_string_literal: true

module Catalog
  class Bead < ApplicationRecord
    # Set the table name explicitly to match the database
    self.table_name = 'beads'

    # Associations (only brand remains, others replaced by columns)
    belongs_to :brand, class_name: 'Catalog::BeadBrand', inverse_of: :beads

    # Removed associations (tables deleted):
    # belongs_to :size, class_name: 'Catalog::BeadSize', inverse_of: :beads
    # belongs_to :type, class_name: 'Catalog::BeadType', inverse_of: :beads
    # has_many :bead_color_links, class_name: 'Catalog::BeadColorLink', dependent: :destroy, inverse_of: :bead
    # has_many :colors, through: :bead_color_links, source: :color, class_name: 'Catalog::BeadColor'
    # has_many :bead_finish_links, class_name: 'Catalog::BeadFinishLink', dependent: :destroy, inverse_of: :bead
    # has_many :finishes, through: :bead_finish_links, source: :finish, class_name: 'Catalog::BeadFinish'

    # Validations
    validates :name, presence: true
    validates :brand_product_code, presence: true, uniqueness: true

    # New detailed attribute validations (commented out for now)
    # validates :shape, presence: true, inclusion: { in: %w[Delica Rocailles Round Cube Cylinder Triangle Square] }
    # validates :size, presence: true, inclusion: { in: %w[11/0 8/0 6/0 15/0 12/0 10/0 8/0 6/0 5/0 4/0 3/0 2/0 1/0 1 2 3 4 5 6] }
    # validates :color_group, presence: true, inclusion: { in: %w[red pink orange yellow green blue purple brown black white gray silver gold] }
    # validates :glass_group, presence: true, inclusion: { in: %w[Opaque Transparent Translucent Iridescent Metallic] }
    # validates :finish, presence: true, inclusion: { in: %w[Matte Glossy Pearl Metallic Iridescent] }
    # validates :dyed, presence: true, inclusion: { in: %w[Dyed Non-dyed] }
    # validates :galvanized, presence: true, inclusion: { in: %w[Galvanized Non-galvanized] }
    # validates :plating, presence: true, inclusion: { in: %w[Plating Non-plating] }

    # Scopes for filtering
    scope :by_shape, ->(shape) { where(shape: shape) }
    scope :by_size, ->(size) { where(size: size) }
    scope :by_color_group, ->(color_group) { where(color_group: color_group) }
    scope :by_glass_group, ->(glass_group) { where(glass_group: glass_group) }
    scope :by_finish, ->(finish) { where(finish: finish) }
    scope :by_dyed, ->(dyed) { where(dyed: dyed) }
    scope :by_galvanized, ->(galvanized) { where(galvanized: galvanized) }
    scope :by_plating, ->(plating) { where(plating: plating) }
  end
end

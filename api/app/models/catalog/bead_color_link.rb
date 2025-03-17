# frozen_string_literal: true

module Catalog
  class BeadColorLink < ApplicationRecord
    # Associations
    belongs_to :bead, class_name: 'Catalog::Bead'
    belongs_to :color, class_name: 'Catalog::BeadColor'

    # Validations
    validates :bead_id, uniqueness: { scope: :color_id }
  end
end
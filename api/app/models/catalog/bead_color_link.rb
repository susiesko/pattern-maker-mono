module Catalog
  class BeadColorLink < ApplicationRecord
    belongs_to :bead
    belongs_to :color, class_name: "Catalog::BeadColor", foreign_key: :color_id

    validates :bead_id, uniqueness: { scope: :color_id }
  end
end

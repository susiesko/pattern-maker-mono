# frozen_string_literal: true

module Catalog
  class BeadColor < ApplicationRecord
    has_many :bead_color_links, foreign_key: :color_id, dependent: :destroy
    has_many :beads, through: :bead_color_links

    validates :name, presence: true
  end
end

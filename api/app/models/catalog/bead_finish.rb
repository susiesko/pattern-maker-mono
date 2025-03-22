# frozen_string_literal: true

module Catalog
  class BeadFinish < ApplicationRecord
    # Associations
    has_many :bead_finish_links, foreign_key: :finish_id, dependent: :destroy
    has_many :beads, through: :bead_finish_links

    # Validations
    validates :name, presence: true
  end
end

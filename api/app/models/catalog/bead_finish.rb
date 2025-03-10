# frozen_string_literal: true

module Catalog
  class BeadFinish < ApplicationRecord
    has_many :bead_finish_links, foreign_key: :finish_id, dependent: :destroy
    has_many :beads, through: :bead_finish_links

    validates :name, presence: true
  end
end

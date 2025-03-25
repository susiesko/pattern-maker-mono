# frozen_string_literal: true

module Catalog
  class BeadFinish < ApplicationRecord
    # Set the table name explicitly to match the database
    self.table_name = 'bead_finishes'

    # Associations
    has_many :bead_finish_links, class_name: 'Catalog::BeadFinishLink', foreign_key: 'finish_id', dependent: :destroy
    has_many :beads, through: :bead_finish_links, class_name: 'Catalog::Bead'

    # Validations
    validates :name, presence: true
  end
end

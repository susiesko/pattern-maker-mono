# frozen_string_literal: true

module Catalog
  class BeadFinishLink < ApplicationRecord
    # Set the table name explicitly to match the database
    self.table_name = 'bead_finish_links'

    # Associations
    belongs_to :bead, class_name: 'Catalog::Bead', foreign_key: 'bead_id'
    belongs_to :finish, class_name: 'Catalog::BeadFinish', foreign_key: 'finish_id'

    # Validations
    validates :bead_id, uniqueness: { scope: :finish_id }
  end
end

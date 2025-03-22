# frozen_string_literal: true

module Catalog
  class BeadFinishLink < ApplicationRecord
    # Associations
    belongs_to :bead, class_name: 'Catalog::Bead'
    belongs_to :finish, class_name: 'Catalog::BeadFinish'

    # Validations
    validates :bead_id, uniqueness: { scope: :finish_id }
  end
end

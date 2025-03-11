# frozen_string_literal: true

module Catalog
  class BeadFinishLink < ApplicationRecord
    belongs_to :bead
    belongs_to :finish, class_name: 'Catalog::BeadFinish', foreign_key: :finish_id

    validates :bead_id, uniqueness: { scope: :finish_id }
  end
end

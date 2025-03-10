# frozen_string_literal: true

module Catalog
  class FetchBeadService
    attr_reader :id

    def initialize(id)
      @id = id
    end

    def call
      Catalog::Bead.includes(:brand, :size, :type, :colors, :finishes).find(id)
    end
  end
end

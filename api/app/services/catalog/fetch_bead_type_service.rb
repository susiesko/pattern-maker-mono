# frozen_string_literal: true

module Catalog
  class FetchBeadTypeService < ApplicationService
    attr_reader :id

    def initialize(id)
      @id = id
    end

    def call
      Catalog::BeadType.includes(:brand).find(id)
    end
  end
end

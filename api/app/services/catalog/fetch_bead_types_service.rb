# frozen_string_literal: true

module Catalog
  class FetchBeadTypesService
    attr_reader :params

    def initialize(params = {})
      @params = params
    end

    def call
      Catalog::BeadTypeQuery.new.call(params)
    end
  end
end

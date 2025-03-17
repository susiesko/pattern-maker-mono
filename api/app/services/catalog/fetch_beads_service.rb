# frozen_string_literal: true

module Catalog
  class FetchBeadsService < ApplicationService
    attr_reader :params

    def initialize(params = {})
      @params = params
    end

    def call
      Catalog::BeadQuery.new.call(params)
    end
  end
end

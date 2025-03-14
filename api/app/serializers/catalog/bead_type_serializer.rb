# frozen_string_literal: true

module Catalog
  class BeadTypeSerializer < ActiveModel::Serializer
    attributes :id, :name, :created_at, :updated_at

    belongs_to :brand do
      object.brand.as_json(only: [:id, :name, :website])
    end
  end
end

# frozen_string_literal: true

module Catalog
  class BeadTypeQuery
    attr_reader :relation

    def initialize(relation = Catalog::BeadType.all)
      @relation = relation
    end

    def call(params = {})
      result = relation
      result = filter_by_brand(result, params[:brand_id])
      result = search(result, params[:search])
      result = sort(result, params[:sort_by], params[:sort_direction])
      includes_associations(result)
    end

    private

      def filter_by_brand(relation, brand_id)
        return relation if brand_id.blank?

        relation.where(brand_id: brand_id)
      end

      def search(relation, search_term)
        return relation if search_term.blank?

        term = "%#{search_term}%"
        relation.where('name ILIKE ?', term)
      end

      def sort(relation, sort_by, sort_direction)
        sort_column = sort_by || 'name'
        sort_direction ||= 'asc'

        # Ensure sort_column is a valid column to prevent SQL injection
        valid_columns = %w[name created_at updated_at]
        sort_column = 'name' unless valid_columns.include?(sort_column)

        # Ensure sort_direction is either 'asc' or 'desc'
        sort_direction = sort_direction.to_s.downcase == 'asc' ? 'asc' : 'desc'

        relation.order("#{sort_column} #{sort_direction}")
      end

      def includes_associations(relation)
        relation.includes(:brand)
      end
  end
end

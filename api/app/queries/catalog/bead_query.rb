# frozen_string_literal: true

module Catalog
  class BeadQuery
    VALID_SORT_COLUMNS = %w[name brand_product_code created_at updated_at].freeze
    DEFAULT_SORT_COLUMN = 'created_at'
    DEFAULT_SORT_DIRECTION = 'desc'

    attr_reader :relation

    def initialize(relation = Catalog::Bead.all)
      @relation = relation
    end

    def call(params = {})
      result = relation

      # Apply direct attribute filters
      [:brand_id, :type_id, :size_id].each do |attribute|
        result = filter_by_attribute(result, attribute, params[attribute])
      end

      # Apply association filters
      result = filter_by_association(result, :bead_color_links, :color_id, params[:color_id])
      result = filter_by_association(result, :bead_finish_links, :finish_id, params[:finish_id])

      # Apply search and sort
      result = search(result, params[:search])
      result = sort(result, params[:sort_by], params[:sort_direction])

      includes_associations(result)
    end

    private

      def filter_by_attribute(relation, attribute, value)
        return relation if value.blank?

        relation.where(attribute => value)
      end

      def filter_by_association(relation, join_table, attribute, value)
        return relation if value.blank?

        relation.joins(join_table).where(join_table => { attribute => value }).distinct
      end

      def search(relation, search_term)
        return relation if search_term.blank?

        term = "%#{search_term}%"
        relation.where('name ILIKE ? OR brand_product_code ILIKE ?', term, term)
      end

      def sort(relation, sort_by, sort_direction)
        # Validate sort column
        sort_column = VALID_SORT_COLUMNS.include?(sort_by) ? sort_by : DEFAULT_SORT_COLUMN

        # Validate sort direction
        sort_direction = sort_direction.to_s.downcase == 'asc' ? 'asc' : DEFAULT_SORT_DIRECTION

        relation.order("#{sort_column} #{sort_direction}")
      end

      def includes_associations(relation)
        relation.includes(:brand, :size, :type, :colors, :finishes)
      end
  end
end

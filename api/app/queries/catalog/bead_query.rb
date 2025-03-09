module Catalog
  class BeadQuery
    attr_reader :relation

    def initialize(relation = Catalog::Bead.all)
      @relation = relation
    end

    def call(params = {})
      result = relation
      result = filter_by_brand(result, params[:brand_id])
      result = filter_by_type(result, params[:type_id])
      result = filter_by_size(result, params[:size_id])
      result = filter_by_color(result, params[:color_id])
      result = filter_by_finish(result, params[:finish_id])
      result = search(result, params[:search])
      result = sort(result, params[:sort_by], params[:sort_direction])
      result = includes_associations(result)
      result
    end

    private

    def filter_by_brand(relation, brand_id)
      return relation if brand_id.blank?
      relation.where(brand_id: brand_id)
    end

    def filter_by_type(relation, type_id)
      return relation if type_id.blank?
      relation.where(type_id: type_id)
    end

    def filter_by_size(relation, size_id)
      return relation if size_id.blank?
      relation.where(size_id: size_id)
    end

    def filter_by_color(relation, color_id)
      return relation if color_id.blank?
      relation.joins(:bead_color_links).where(bead_color_links: { color_id: color_id }).distinct
    end

    def filter_by_finish(relation, finish_id)
      return relation if finish_id.blank?
      relation.joins(:bead_finish_links).where(bead_finish_links: { finish_id: finish_id }).distinct
    end

    def search(relation, search_term)
      return relation if search_term.blank?
      term = "%#{search_term}%"
      relation.where("name ILIKE ? OR brand_product_code ILIKE ?", term, term)
    end

    def sort(relation, sort_by, sort_direction)
      sort_column = sort_by || 'created_at'
      sort_direction = sort_direction || 'desc'
      
      # Ensure sort_column is a valid column to prevent SQL injection
      valid_columns = ['name', 'brand_product_code', 'created_at', 'updated_at']
      sort_column = 'created_at' unless valid_columns.include?(sort_column)
      
      # Ensure sort_direction is either 'asc' or 'desc'
      sort_direction = sort_direction.to_s.downcase == 'asc' ? 'asc' : 'desc'
      
      relation.order("#{sort_column} #{sort_direction}")
    end

    def includes_associations(relation)
      relation.includes(:brand, :size, :type, :colors, :finishes)
    end
  end
end
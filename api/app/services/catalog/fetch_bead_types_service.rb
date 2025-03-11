require 'ostruct'

module Catalog
  class FetchBeadTypesService
    attr_reader :params, :controller

    def initialize(params = {}, controller = nil)
      @params = params
      @controller = controller
    end

    def call
      bead_types = Catalog::BeadTypeQuery.new.call(params)

      if controller.present?
        # Use the controller's pagy method if available
        pagy, paginated_bead_types = controller.send(:pagy, bead_types, items: params[:items] || 20)
      else
        # Fallback to manual pagination for testing or non-controller contexts
        page = (params[:page] || 1).to_i
        items_per_page = (params[:items] || 20).to_i
        total_count = bead_types.count

        paginated_bead_types = bead_types.offset((page - 1) * items_per_page).limit(items_per_page)

        # Create a simple pagy-like object with the necessary attributes
        pagy = OpenStruct.new(
          page: page,
          items: items_per_page,
          pages: (total_count.to_f / items_per_page).ceil,
          count: total_count,
          next: page < (total_count.to_f / items_per_page).ceil ? page + 1 : nil,
          prev: page > 1 ? page - 1 : nil
        )
      end

      [pagy, paginated_bead_types]
    end
  end
end
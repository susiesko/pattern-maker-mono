# frozen_string_literal: true

module Catalog
  class FetchBeadsService
    DEFAULT_ITEMS_PER_PAGE = 20
    DEFAULT_PAGE = 1

    attr_reader :params, :controller

    def initialize(params = {}, controller = nil)
      @params = params
      @controller = controller
    end

    def call
      beads = Catalog::BeadQuery.new.call(params)

      if controller.present?
        paginate_with_controller(beads)
      else
        paginate_manually(beads)
      end
    end

    private

      def paginate_with_controller(beads)
        items = params[:items] || DEFAULT_ITEMS_PER_PAGE
        controller.send(:pagy, beads, items: items)
      end

      def paginate_manually(beads)
        page = (params[:page] || DEFAULT_PAGE).to_i
        items_per_page = (params[:items] || DEFAULT_ITEMS_PER_PAGE).to_i
        total_count = beads.count

        paginated_beads = beads.offset((page - 1) * items_per_page).limit(items_per_page)
        pagy = create_pagy_struct(page, items_per_page, total_count)

        [pagy, paginated_beads]
      end

      def create_pagy_struct(page, items_per_page, total_count)
        total_pages = calculate_total_pages(total_count, items_per_page)

        Struct.new(
          page: page,
          items: items_per_page,
          pages: total_pages,
          count: total_count,
          next: page < total_pages ? page + 1 : nil,
          prev: page > 1 ? page - 1 : nil
        )
      end

      def calculate_total_pages(total_count, items_per_page)
        (total_count.to_f / items_per_page).ceil
      end
  end
end

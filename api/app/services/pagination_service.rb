class PaginationService
  DEFAULT_LIMIT = 20
  MAX_LIMIT = 100

  def initialize(relation, page: 1, per_page: DEFAULT_LIMIT)
    @relation = relation
    @page = [page.to_i, 1].max # Ensure page is at least 1
    @per_page = [[per_page.to_i, 1].max, MAX_LIMIT].min # Ensure per_page is between 1 and MAX_LIMIT
    @per_page = DEFAULT_LIMIT if @per_page <= 0
  end

  def paginate
    # Get total count for pagination info
    total_count = @relation.count
    total_pages = (total_count.to_f / @per_page).ceil

    # Calculate offset
    offset = (@page - 1) * @per_page

    # Get the records for this page
    records = @relation.offset(offset).limit(@per_page)

    {
      records: records,
      pagination: {
        current_page: @page,
        per_page: @per_page,
        total_count: total_count,
        total_pages: total_pages,
        has_more: @page < total_pages,
        has_previous: @page > 1,
      },
    }
  end
end

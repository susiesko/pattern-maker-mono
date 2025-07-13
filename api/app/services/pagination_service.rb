class PaginationService
  DEFAULT_LIMIT = 20
  MAX_LIMIT = 100
  
  def initialize(relation, cursor: nil, limit: DEFAULT_LIMIT, cursor_field: :id, direction: :desc)
    @relation = relation
    @cursor = cursor
    @cursor_field = cursor_field
    @direction = direction
    @limit = [limit.to_i, MAX_LIMIT].min
    @limit = DEFAULT_LIMIT if @limit <= 0
  end
  
  def paginate
    records = build_query.limit(@limit + 1) # +1 to check if more exist
    
    has_more = records.size > @limit
    records = records.first(@limit) if has_more
    
    {
      records: records,
      has_more: has_more,
      next_cursor: has_more ? records.last&.send(@cursor_field) : nil,
      limit: @limit
    }
  end
  
  private
  
  def build_query
    if @cursor.present?
      operator = @direction == :desc ? '<' : '>'
      @relation.where("#{@cursor_field} #{operator} ?", @cursor)
    else
      @relation
    end
  end
end 
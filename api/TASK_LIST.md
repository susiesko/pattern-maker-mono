# Task List

## Database Performance & Monitoring

### High Priority

- [ ] **Set up database monitoring** to identify slow queries
  - [ ] Configure PostgreSQL query logging
  - [ ] Set up pg_stat_statements extension
  - [ ] Create dashboard for query performance metrics
  - [ ] Monitor DISTINCT queries in bead controllers
  - [ ] Monitor filtering performance in beads API

### Medium Priority

- [ ] **Add indexes based on actual performance data**
  - [ ] Analyze which bead fields are most commonly filtered
  - [ ] Add indexes only for proven slow queries
  - [ ] Consider partial indexes for specific filter patterns
  - [ ] Test index impact on write performance

### Low Priority

- [ ] **Optimize bulk import process**
  - [ ] Research bulk_insert gems vs individual saves
  - [ ] Test PostgreSQL COPY commands for large imports
  - [ ] Consider staging table approach for large imports

## API & Frontend

### High Priority

- [ ] **Test updated controllers with real data**
  - [ ] Verify bead_sizes_controller returns correct data
  - [ ] Verify bead_colors_controller returns correct data
  - [ ] Verify bead_finishes_controller returns correct data
  - [ ] Verify bead_types_controller returns correct data

### Medium Priority

- [ ] **Frontend integration testing**
  - [ ] Test filtering with new simplified bead structure
  - [ ] Update frontend to use new bead attributes
  - [ ] Test search functionality with new structure

## Crawler & Data Import

### High Priority

- [ ] **Implement retry logic in crawler**
  - [ ] Add exponential backoff for failed requests
  - [ ] Handle network timeouts gracefully
  - [ ] Add logging for failed crawls

### Medium Priority

- [ ] **Enable HTTP caching middleware**
  - [ ] Configure cache headers for development
  - [ ] Test caching impact on crawler performance
  - [ ] Monitor memory usage with caching

## Performance Optimization

### Medium Priority

- [ ] **Redis caching for beads API**
  - [ ] Cache DISTINCT queries results
  - [ ] Cache filtered bead lists
  - [ ] Implement cache invalidation strategy

### Low Priority

- [ ] **Frontend performance optimizations**
  - [ ] Implement virtual scrolling for large bead lists
  - [ ] Add debounce to search inputs
  - [ ] Optimize React component re-renders

## Testing & Quality

### Medium Priority

- [ ] **Add integration tests for new controllers**
  - [ ] Test bead_sizes_controller with real data
  - [ ] Test bead_colors_controller with real data
  - [ ] Test bead_finishes_controller with real data
  - [ ] Test bead_types_controller with real data

### Low Priority

- [ ] **Revisit skipped debounce tests**
  - [ ] Fix BeadSearch component debounce tests
  - [ ] Add proper async testing patterns

## Notes

- Database indexes will be added incrementally based on actual performance monitoring
- Focus on getting real usage data before optimizing
- Monitor both read and write performance impacts

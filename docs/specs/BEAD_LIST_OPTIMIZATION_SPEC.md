# Bead List Page Optimization Specification

## Executive Summary

This specification outlines a comprehensive optimization strategy for the bead list page, targeting both backend API performance and frontend UI responsiveness. The goal is to handle large datasets efficiently while maintaining excellent user experience.

## Current State Analysis

### Current Performance Characteristics
- **API**: Simple REST endpoints returning full object graphs
- **Database**: Basic ActiveRecord queries without optimization
- **UI**: Client-side filtering and sorting of full dataset
- **Rendering**: Standard React list rendering without virtualization
- **Images**: Standard image loading without optimization

### Identified Performance Bottlenecks
1. **N+1 Query Problems**: Loading beads with associated brands, types, colors, finishes
2. **Large Payload Size**: Full object graphs transmitted for all beads
3. **Memory Usage**: Large datasets loaded entirely in browser memory
4. **Image Loading**: All images load simultaneously causing network congestion
5. **Re-rendering**: Unnecessary React re-renders on filter/sort operations

## Performance Goals

### API Performance Targets
- **Response Time**: < 200ms for paginated requests
- **Throughput**: Support 100+ concurrent users
- **Memory Usage**: < 500MB Rails server memory per worker
- **Database Queries**: < 5 queries per bead list request

### UI Performance Targets
- **Initial Load**: < 2 seconds to first meaningful paint
- **Scroll Performance**: 60 FPS during scrolling
- **Search Response**: < 100ms debounced search response
- **Memory Usage**: < 200MB browser memory for 1000+ beads
- **Bundle Size**: < 500KB gzipped for bead list features

## API Optimizations

### 1. Database Query Optimization

#### Problem
Current implementation suffers from N+1 queries when loading bead associations.

```ruby
# Current problematic approach
beads = Bead.all
beads.each { |bead| puts bead.brand.name } # N+1 queries
```

#### Solution
Implement eager loading and query optimization.

```ruby
# Optimized approach
class Api::V1::Catalog::BeadsController < Api::V1::BaseController
  def index
    @beads = Bead.includes(:brand, :type, :size, :colors, :finishes)
                 .with_attached_image
                 .page(params[:page])
                 .per(params[:per_page] || 50)
    
    render json: BeadListSerializer.new(@beads, include_params)
  end

  private

  def include_params
    {
      include: [:brand, :type, :size, :colors, :finishes],
      fields: field_params
    }
  end
end
```

#### Database Indexing Strategy
```sql
-- Add composite indexes for common query patterns
CREATE INDEX idx_beads_brand_type ON beads(brand_id, type_id);
CREATE INDEX idx_beads_search ON beads USING gin(to_tsvector('english', name));
CREATE INDEX idx_beads_created_at ON beads(created_at DESC);

-- Optimize association lookups
CREATE INDEX idx_bead_color_links_bead_id ON bead_color_links(bead_id);
CREATE INDEX idx_bead_finish_links_bead_id ON bead_finish_links(bead_id);
```

### 2. Pagination Implementation

#### Cursor-Based Pagination
Implement efficient cursor-based pagination for better performance with large datasets.

```ruby
class PaginationService
  def self.paginate(scope, cursor: nil, limit: 50)
    if cursor.present?
      decoded_cursor = Base64.decode64(cursor)
      timestamp, id = decoded_cursor.split(',')
      scope = scope.where('(created_at < ? OR (created_at = ? AND id < ?))', 
                         timestamp, timestamp, id.to_i)
    end
    
    records = scope.order(created_at: :desc, id: :desc).limit(limit + 1)
    has_next = records.length > limit
    records = records.limit(limit) if has_next
    
    next_cursor = if has_next && records.any?
      last_record = records.last
      Base64.encode64("#{last_record.created_at.iso8601},#{last_record.id}")
    end

    {
      data: records,
      pagination: {
        has_next: has_next,
        next_cursor: next_cursor,
        limit: limit
      }
    }
  end
end
```

### 3. Caching Strategy

#### Multi-Level Caching Implementation
```ruby
class BeadCacheService
  CACHE_TTL = 1.hour

  def self.cached_bead_list(cache_key, &block)
    Rails.cache.fetch(cache_key, expires_in: CACHE_TTL) do
      yield
    end
  end

  def self.cache_key_for_filters(filters, page, per_page)
    filter_hash = Digest::SHA256.hexdigest(filters.to_json)
    "bead_list:#{filter_hash}:#{page}:#{per_page}"
  end

  def self.invalidate_bead_caches
    Rails.cache.delete_matched("bead_list:*")
  end
end

# In BeadsController
def index
  cache_key = BeadCacheService.cache_key_for_filters(
    filter_params, params[:page], params[:per_page]
  )
  
  @beads = BeadCacheService.cached_bead_list(cache_key) do
    build_bead_query.page(params[:page]).per(params[:per_page])
  end
  
  # Set cache headers
  expires_in 5.minutes, public: true
  
  render json: BeadListSerializer.new(@beads)
end
```

## UI Optimizations

### 1. Virtual Scrolling Implementation

#### React Window Integration
```typescript
// components/catalog/VirtualizedBeadList.tsx
import React, { useMemo } from 'react';
import { FixedSizeList as List } from 'react-window';
import { BeadCard } from './BeadCard';
import { Bead } from '../../types/beads';

interface VirtualizedBeadListProps {
  beads: Bead[];
  onEdit: (id: number) => void;
  onView: (id: number) => void;
  height: number;
  width: number;
}

const VirtualizedBeadList: React.FC<VirtualizedBeadListProps> = ({
  beads,
  onEdit,
  onView,
  height,
  width
}) => {
  const ITEM_HEIGHT = 200; // Height of each bead card
  const ITEMS_PER_ROW = Math.floor(width / 300); // Cards per row based on width

  const itemData = useMemo(() => ({
    beads,
    onEdit,
    onView,
    itemsPerRow: ITEMS_PER_ROW
  }), [beads, onEdit, onView, ITEMS_PER_ROW]);

  const Row = ({ index, style, data }: any) => {
    const { beads, onEdit, onView, itemsPerRow } = data;
    const startIndex = index * itemsPerRow;
    const endIndex = Math.min(startIndex + itemsPerRow, beads.length);
    const rowBeads = beads.slice(startIndex, endIndex);

    return (
      <div style={style}>
        <div style={{ display: 'flex', gap: '16px', padding: '8px' }}>
          {rowBeads.map((bead: Bead) => (
            <BeadCard
              key={bead.id}
              bead={bead}
              onEdit={onEdit}
              onView={onView}
            />
          ))}
        </div>
      </div>
    );
  };

  const itemCount = Math.ceil(beads.length / ITEMS_PER_ROW);

  return (
    <List
      height={height}
      itemCount={itemCount}
      itemSize={ITEM_HEIGHT}
      itemData={itemData}
      width={width}
    >
      {Row}
    </List>
  );
};

export default VirtualizedBeadList;
```

### 2. Image Optimization

#### Lazy Loading with Intersection Observer
```typescript
// hooks/useLazyImage.ts
import { useState, useEffect, useRef } from 'react';

interface UseLazyImageProps {
  src: string;
  placeholder?: string;
  rootMargin?: string;
}

export const useLazyImage = ({ src, placeholder, rootMargin = '50px' }: UseLazyImageProps) => {
  const [imageSrc, setImageSrc] = useState(placeholder);
  const [isLoaded, setIsLoaded] = useState(false);
  const imgRef = useRef<HTMLImageElement>(null);

  useEffect(() => {
    let observer: IntersectionObserver;
    
    if (imgRef.current && src) {
      observer = new IntersectionObserver(
        ([entry]) => {
          if (entry.isIntersecting) {
            setImageSrc(src);
            observer.disconnect();
          }
        },
        { rootMargin }
      );

      observer.observe(imgRef.current);
    }

    return () => {
      if (observer) observer.disconnect();
    };
  }, [src, rootMargin]);

  const handleLoad = () => setIsLoaded(true);

  return { imageSrc, isLoaded, imgRef, handleLoad };
};
```

## Implementation Plan

### Phase 1: API Optimizations (Week 1-2)
1. **Database Optimization**
   - Add database indexes
   - Implement eager loading
   - Optimize N+1 queries

2. **Pagination Implementation**
   - Implement cursor-based pagination
   - Update API endpoints
   - Add pagination metadata

### Phase 2: Caching Layer (Week 2-3)
1. **Response Caching**
   - Implement Redis caching
   - Add cache invalidation strategies
   - Set up cache headers

2. **API Response Optimization**
   - Implement selective field loading
   - Add response compression
   - Optimize serializers

### Phase 3: UI Performance (Week 3-4)
1. **Virtual Scrolling**
   - Implement react-window
   - Add infinite scrolling
   - Optimize rendering

2. **Image Optimization**
   - Add lazy loading
   - Implement responsive images
   - Add progressive loading

### Phase 4: React Optimization (Week 4-5)
1. **Component Optimization**
   - Add proper memoization
   - Optimize re-renders
   - Implement callback optimization

2. **Bundle Optimization**
   - Add code splitting
   - Optimize bundle size
   - Implement tree shaking

## Success Metrics

### Performance Metrics
- **API Response Time**: Target < 200ms (baseline: ~800ms)
- **Time to First Contentful Paint**: Target < 1.5s (baseline: ~3s)
- **Largest Contentful Paint**: Target < 2.5s (baseline: ~5s)
- **First Input Delay**: Target < 100ms (baseline: ~300ms)
- **Cumulative Layout Shift**: Target < 0.1 (baseline: ~0.3)

### Technical Metrics
- **Database Query Count**: Target < 5 queries per request (baseline: 50+)
- **Memory Usage (Server)**: Target < 500MB per worker (baseline: 1GB+)
- **Memory Usage (Client)**: Target < 200MB for 1000 beads (baseline: 500MB+)
- **Bundle Size**: Target < 500KB gzipped (baseline: 1.2MB)

### User Experience Metrics
- **Search Response Time**: Target < 100ms (baseline: 500ms)
- **Scroll Performance**: Target 60 FPS (baseline: 30 FPS)
- **Image Load Time**: Target < 1s per image (baseline: 3s+) 
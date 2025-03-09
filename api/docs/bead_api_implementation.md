# Bead Catalog API Implementation Guide

This document provides a comprehensive guide to the implementation of the Bead Catalog API, focusing on the bead retrieval endpoints with filtering and pagination.

## Overview

The API follows RESTful principles and is versioned (v1) to allow for future changes without breaking existing clients. It uses Pagy for efficient pagination and Active Model Serializers for JSON serialization. The implementation follows the Single Responsibility Principle by separating concerns into controllers, query objects, and service objects.

## Files Structure

```
app/
├── controllers/
│   ├── api/
│   │   └── v1/
│   │       ├── base_controller.rb
│   │       └── beads_controller.rb
│   └── application_controller.rb
├── models/
│   └── catalog/
│       ├── bead.rb
│       ├── bead_brand.rb
│       ├── bead_color.rb
│       ├── bead_color_link.rb
│       ├── bead_finish.rb
│       ├── bead_finish_link.rb
│       ├── bead_size.rb
│       └── bead_type.rb
├── queries/
│   └── catalog/
│       └── bead_query.rb
├── services/
│   └── catalog/
│       ├── fetch_bead_service.rb
│       └── fetch_beads_service.rb
├── serializers/
│   └── bead_serializer.rb
└── views/
config/
├── initializers/
│   ├── active_model_serializers.rb
│   └── pagy.rb
└── routes.rb
```

## Implementation Details

### 1. Gemfile

```ruby
# pagination - using Pagy for better performance and security
gem "pagy"

# API serialization
gem "active_model_serializers"
```

### 2. Routes Configuration

```ruby
# config/routes.rb
Rails.application.routes.draw do
  # API routes
  namespace :api do
    namespace :v1 do
      resources :beads, only: [:index, :show]

      # Additional catalog resources
      resources :bead_brands, only: [:index, :show], path: 'brands'
      resources :bead_types, only: [:index, :show], path: 'types'
      resources :bead_sizes, only: [:index, :show], path: 'sizes'
      resources :bead_colors, only: [:index, :show], path: 'colors'
      resources :bead_finishes, only: [:index, :show], path: 'finishes'
    end
  end
end
```

### 3. Base API Controller

```ruby
# app/controllers/api/v1/base_controller.rb
module Api
  module V1
    class BaseController < ApplicationController
      include Pagy::Backend

      skip_before_action :verify_authenticity_token, if: :json_request?

      protected

      def json_request?
        request.format.json?
      end

      def pagy_metadata(pagy)
        {
          current_page: pagy.page,
          next_page: pagy.next,
          prev_page: pagy.prev,
          total_pages: pagy.pages,
          total_count: pagy.count,
          per_page: pagy.items
        }
      end
    end
  end
end
```

### 4. Beads Controller

```ruby
# app/controllers/api/v1/beads_controller.rb
module Api
  module V1
    class BeadsController < BaseController
      def index
        @pagy, @beads = Catalog::FetchBeadsService.new(filter_params, self).call

        render json: {
          beads: ActiveModelSerializers::SerializableResource.new(@beads, each_serializer: BeadSerializer),
          meta: pagy_metadata(@pagy)
        }
      end

      def show
        @bead = Catalog::FetchBeadService.new(params[:id]).call
        render json: @bead, serializer: BeadSerializer
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Bead not found" }, status: :not_found
      end

      private

      def filter_params
        params.permit(:brand_id, :type_id, :size_id, :color_id, :finish_id, :search, :sort_by, :sort_direction, :items, :page)
      end
    end
  end
end
```

### 5. Bead Query Object

```ruby
# app/queries/catalog/bead_query.rb
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
```

### 6. Fetch Beads Service

```ruby
# app/services/catalog/fetch_beads_service.rb
module Catalog
  class FetchBeadsService
    attr_reader :params, :controller

    def initialize(params = {}, controller = nil)
      @params = params
      @controller = controller
    end

    def call
      beads = Catalog::BeadQuery.new.call(params)

      if controller.present?
        # Use the controller's pagy method if available
        pagy, paginated_beads = controller.send(:pagy, beads, items: params[:items] || 20)
      else
        # Fallback to manual pagination for testing or non-controller contexts
        page = (params[:page] || 1).to_i
        items_per_page = (params[:items] || 20).to_i
        total_count = beads.count

        paginated_beads = beads.offset((page - 1) * items_per_page).limit(items_per_page)

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

      [pagy, paginated_beads]
    end
  end
end
```

### 7. Fetch Bead Service

```ruby
# app/services/catalog/fetch_bead_service.rb
module Catalog
  class FetchBeadService
    attr_reader :id

    def initialize(id)
      @id = id
    end

    def call
      Catalog::Bead.includes(:brand, :size, :type, :colors, :finishes).find(id)
    end
  end
end
```

### 8. Bead Serializer

```ruby
# app/serializers/bead_serializer.rb
class BeadSerializer < ActiveModel::Serializer
  attributes :id, :name, :brand_product_code, :image, :metadata, :created_at, :updated_at

  belongs_to :brand do
    object.brand.as_json(only: [:id, :name, :website])
  end

  belongs_to :size do
    object.size.as_json(only: [:id, :size])
  end

  belongs_to :type do
    object.type.as_json(only: [:id, :name])
  end

  has_many :colors do
    object.colors.as_json(only: [:id, :name])
  end

  has_many :finishes do
    object.finishes.as_json(only: [:id, :name])
  end
end
```

### 9. Pagy Configuration

```ruby
# config/initializers/pagy.rb
# frozen_string_literal: true

# Pagy initializer file
Pagy::DEFAULT[:items] = 20        # items per page
Pagy::DEFAULT[:size]  = [1, 4, 4, 1] # nav bar links
Pagy::DEFAULT[:page]   = 1        # default page
Pagy::DEFAULT[:outset] = 0        # starting offset

# Backend
require 'pagy/extras/overflow'
Pagy::DEFAULT[:overflow] = :empty_page    # default handling of the #pagy overflow

# Headers extra: Add Pagy headers for easier frontend implementation
require 'pagy/extras/headers'
Pagy::DEFAULT[:headers] = { page: 'Current-Page', items: 'Page-Items', count: 'Total-Count', pages: 'Total-Pages' }

# Support for arrays
require 'pagy/extras/array'

# Allow for larger page sizes when requested
Pagy::DEFAULT[:max_items] = 100   # default max items per page
```

### 10. Active Model Serializers Configuration

```ruby
# config/initializers/active_model_serializers.rb
# frozen_string_literal: true

ActiveModelSerializers.config.adapter = :json
```

## Key Features

### Architecture

The implementation follows a clean architecture approach:

- **Controllers**: Handle HTTP requests and responses
- **Query Objects**: Encapsulate database query logic
- **Service Objects**: Orchestrate business logic
- **Serializers**: Format data for API responses

This separation of concerns makes the code more maintainable, testable, and easier to understand.

### Pagination

The API uses Pagy for efficient pagination:

- Default page size: 20 items
- Maximum page size: 100 items
- Pagination metadata included in both response body and headers

### Filtering

The API supports filtering beads by:

- Brand ID
- Type ID
- Size ID
- Color ID
- Finish ID
- Text search (name or product code)

### Sorting

Results can be sorted by:

- Name
- Brand product code
- Creation date
- Update date

In either ascending or descending order.

### Performance Optimizations

- Uses `includes` to eager load associations, reducing N+1 query problems
- Uses `distinct` when joining tables to avoid duplicate results
- Validates and sanitizes sort parameters to prevent SQL injection

### Error Handling

- Returns appropriate HTTP status codes
- Provides meaningful error messages
- Handles record not found exceptions

### Testability

The architecture makes testing easier:

- Query objects can be tested in isolation
- Service objects can be tested without HTTP context
- Controllers become thin and focus on HTTP concerns

## Usage Examples

### Basic Request

```
GET /api/v1/beads
```

### Filtered Request

```
GET /api/v1/beads?brand_id=1&color_id=3&search=delica
```

### Paginated Request

```
GET /api/v1/beads?page=2&items=30
```

### Sorted Request

```
GET /api/v1/beads?sort_by=name&sort_direction=asc
```

### Combined Request

```
GET /api/v1/beads?page=1&items=20&brand_id=1&color_id=3&search=delica&sort_by=name&sort_direction=asc
```

## Testing the API

You can test the API using curl:

```bash
curl -X GET "http://localhost:3000/api/v1/beads?page=1&items=20&brand_id=1"
```

Or using a tool like Postman or Insomnia.

## Next Steps

1. Add authentication if needed
2. Implement caching for better performance
3. Add rate limiting to prevent abuse
4. Implement the remaining controllers for other resources
5. Add comprehensive test coverage
# Bead Catalog API Documentation

## Base URL

```
/api/v1
```

## Authentication

Currently, the API does not require authentication.

## Endpoints

### Beads

#### Get All Beads

```
GET /api/v1/beads
```

Returns a paginated list of beads with filtering options.

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| page | integer | Page number (default: 1) |
| items | integer | Items per page (default: 20, max: 100) |
| brand_id | integer | Filter by brand ID |
| type_id | integer | Filter by bead type ID |
| size_id | integer | Filter by bead size ID |
| color_id | integer | Filter by color ID |
| finish_id | integer | Filter by finish ID |
| search | string | Search by name or product code |
| sort_by | string | Sort by field (name, brand_product_code, created_at, updated_at) |
| sort_direction | string | Sort direction (asc, desc) |

**Example Request:**

```
GET /api/v1/beads?page=1&items=20&brand_id=1&color_id=3&search=delica&sort_by=name&sort_direction=asc
```

**Example Response:**

```json
{
  "beads": [
    {
      "id": 1,
      "name": "Delica 11/0 Silver-Lined Crystal",
      "brand_product_code": "DB0041",
      "image": "db0041.jpg",
      "metadata": {},
      "created_at": "2023-03-15T12:30:45Z",
      "updated_at": "2023-03-15T12:30:45Z",
      "brand": {
        "id": 1,
        "name": "Miyuki",
        "website": "https://www.miyuki-beads.co.jp/english/"
      },
      "size": {
        "id": 3,
        "size": "11/0"
      },
      "type": {
        "id": 1,
        "name": "Delica"
      },
      "colors": [
        {
          "id": 2,
          "name": "Silver-Lined Crystal"
        }
      ],
      "finishes": [
        {
          "id": 12,
          "name": "Silver-Lined"
        }
      ]
    },
    // More beads...
  ],
  "meta": {
    "current_page": 1,
    "next_page": 2,
    "prev_page": null,
    "total_pages": 5,
    "total_count": 98,
    "per_page": 20
  }
}
```

> **Note**: The API also includes pagination information in the response headers:
> - `Current-Page`: The current page number
> - `Page-Items`: Number of items per page
> - `Total-Count`: Total number of items
> - `Total-Pages`: Total number of pages

#### Get a Specific Bead

```
GET /api/v1/beads/:id
```

Returns detailed information about a specific bead.

**Example Request:**

```
GET /api/v1/beads/1
```

**Example Response:**

```json
{
  "bead": {
    "id": 1,
    "name": "Delica 11/0 Silver-Lined Crystal",
    "brand_product_code": "DB0041",
    "image": "db0041.jpg",
    "metadata": {},
    "created_at": "2023-03-15T12:30:45Z",
    "updated_at": "2023-03-15T12:30:45Z",
    "brand": {
      "id": 1,
      "name": "Miyuki",
      "website": "https://www.miyuki-beads.co.jp/english/"
    },
    "size": {
      "id": 3,
      "size": "11/0"
    },
    "type": {
      "id": 1,
      "name": "Delica"
    },
    "colors": [
      {
        "id": 2,
        "name": "Silver-Lined Crystal"
      }
    ],
    "finishes": [
      {
        "id": 12,
        "name": "Silver-Lined"
      }
    ]
  }
}
```

### Other Endpoints

The API also provides endpoints for accessing brands, types, sizes, colors, and finishes:

- `GET /api/v1/brands` - List all bead brands
- `GET /api/v1/brands/:id` - Get a specific bead brand
- `GET /api/v1/types` - List all bead types
- `GET /api/v1/types/:id` - Get a specific bead type
- `GET /api/v1/sizes` - List all bead sizes
- `GET /api/v1/sizes/:id` - Get a specific bead size
- `GET /api/v1/colors` - List all bead colors
- `GET /api/v1/colors/:id` - Get a specific bead color
- `GET /api/v1/finishes` - List all bead finishes
- `GET /api/v1/finishes/:id` - Get a specific bead finish

These endpoints also support pagination with the `page` and `per_page` parameters.

## Error Handling

The API returns appropriate HTTP status codes:

- `200 OK` - Request succeeded
- `400 Bad Request` - Invalid request parameters
- `404 Not Found` - Resource not found
- `500 Internal Server Error` - Server error

Error responses include a message describing the error:

```json
{
  "error": "Record not found"
}
```
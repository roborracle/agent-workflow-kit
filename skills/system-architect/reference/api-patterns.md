# API Design Patterns

## RESTful Endpoints
```
GET    /api/v1/users          # List users (paginated)
GET    /api/v1/users/:id      # Get single user
POST   /api/v1/users          # Create user
PUT    /api/v1/users/:id      # Full update
PATCH  /api/v1/users/:id      # Partial update
DELETE /api/v1/users/:id      # Delete user
GET    /api/v1/users/:id/posts # Nested resource
```

## Success Response
```json
{
  "data": { ... },
  "meta": {
    "page": 1,
    "per_page": 20,
    "total": 100
  }
}
```

## Error Response
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Human-readable description",
    "details": [
      { "field": "email", "message": "Invalid format" }
    ]
  }
}
```

## HTTP Status Codes
| Code | Use |
|------|-----|
| 200 | Success |
| 201 | Created |
| 204 | No Content (successful delete) |
| 400 | Bad Request (validation) |
| 401 | Unauthorized (no/invalid auth) |
| 403 | Forbidden (insufficient permissions) |
| 404 | Not Found |
| 409 | Conflict (duplicate) |
| 422 | Unprocessable Entity |
| 429 | Rate Limited |
| 500 | Internal Server Error |

## Pagination
```
GET /api/v1/users?page=2&per_page=20&sort=created_at&order=desc
```

## Filtering
```
GET /api/v1/users?status=active&role=admin&created_after=2024-01-01
```

## Versioning
- URL path: `/api/v1/`, `/api/v2/`
- Support previous version for minimum 6 months after deprecation

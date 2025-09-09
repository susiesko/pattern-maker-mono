# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Development
- `rails server` - Start Rails API server (runs on port 3000)
- `bundle install` - Install Ruby dependencies
- `rails db:create db:migrate db:seed` - Set up database

### Testing
- `rspec` - Run all RSpec tests
- `rspec spec/models` - Run model tests only
- `rspec spec/controllers` - Run controller tests only
- `rspec spec/requests` - Run request specs
- `rspec --format documentation` - Run tests with detailed output

### Code Quality
- `rubocop` - Run RuboCop linter
- `rubocop -a` - Auto-fix RuboCop issues
- `brakeman` - Run security analysis

### Database
- `rails db:migrate` - Run pending migrations
- `rails db:rollback` - Rollback last migration
- `rails db:reset` - Drop, create, migrate, and seed database
- `rails console` - Interactive Rails console

## Architecture Overview

This is a Rails 8 API-only application that serves as the backend for a bead pattern-making application. The codebase follows standard Rails conventions with some specific organizational patterns:

### Key Models
- **User** - Authentication and user management
- **Catalog::Bead** - Bead catalog items from various brands
- **Catalog::BeadBrand** - Bead manufacturers/brands
- **Inventory** - User's personal bead inventory
- **UserInventorySetting** - User-specific inventory preferences

### Directory Structure
- `app/models/catalog/` - Namespaced catalog models for beads and brands
- `app/controllers/api/v1/` - Versioned API controllers
- `app/services/` - Business logic services (e.g., AuthenticationService, PaginationService)
- `spec/` - RSpec test suite with factories and request specs
- `lib/spiders/` - Legacy Ruby crawlers (note: main crawlers are now in Python)

### Authentication
Uses JWT-based authentication with the AuthenticationService. The JWT secret is configured via environment variables.

### Database
- PostgreSQL primary database
- Uses standard Rails migrations
- Includes seed data for development
- Catalog models are namespaced under `Catalog::`

### API Design
- RESTful API design under `/api/v1/` namespace
- JSON responses only
- CORS configured for cross-origin requests
- Uses PaginationService for paginated responses

### Testing Strategy
- RSpec for all testing
- FactoryBot for test data generation
- Request specs for API endpoint testing
- Model specs for business logic validation
- Uses `--format documentation` for readable test output

### Code Style
- Follows RuboCop configuration in `.rubocop.yml`
- Ruby 3.2 target version
- 120 character line length limit
- Rails, Performance, and RSpec cops enabled
- Excludes standard Rails directories (db/, config/, etc.)

### Development Notes
- This is part of a monorepo with a React frontend (`../ui/`) and Python crawlers (`../crawler/`)
- The application is designed to be deployed on Railway with PostgreSQL
- Environment variables required: `DATABASE_URL`, `JWT_SECRET_KEY`, `ALLOWED_ORIGINS`, `RAILS_MASTER_KEY`
- CORS is configured with environment-based origin allowlist for security
- JWT authentication uses separate secret key (not Rails secret_key_base)
- Contains security vulnerability fixes on the current branch `fix-critical-security-vulnerabilities`
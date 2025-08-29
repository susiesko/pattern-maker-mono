# Pattern Maker Monorepo

A comprehensive bead catalog and inventory management system for jewelry makers and crafters. This monorepo contains a Rails API, React frontend, and Python web crawler for collecting bead data from various suppliers.

## 🏗️ Architecture

```
pattern-maker-mono/
├── api/          # Rails 8 API backend with PostgreSQL
├── ui/           # React + TypeScript frontend with Vite
├── crawler/      # Python web crawler using Scrapy
└── docs/         # Project documentation and specifications
```

## 🚀 Quick Start

### Prerequisites

- **Ruby** 3.3+ (for Rails API)
- **Node.js** 16+ (for React frontend)
- **Python** 3.8+ (for web crawler)
- **PostgreSQL** (primary database)
- **Foreman** (for running all services)

### 1. Clone and Setup

```bash
# Clone the repository
git clone <repository-url>
cd pattern-maker-mono

# Install dependencies for all services
npm install        # Install foreman if not already installed
cd api && bundle install && cd ..
cd ui && npm install && cd ..
cd crawler && pip install -r requirements.txt && cd ..
```

### 2. Database Setup

```bash
cd api
rails db:create
rails db:migrate
rails db:seed
```

### 3. Start All Services

```bash
# From the root directory
foreman start -f Procfile.dev
```

This will start:

- **API**: http://localhost:3000 (Rails server with debugger)
- **UI**: http://localhost:5173 (Vite dev server)

### 4. Optional: Populate with Real Data

```bash
# Run the web crawler to get bead data
cd crawler
python run_fire_mountain_gem_crawler.py

# Import the crawled data into Rails
cd ../api
rails beads:import
```

## 📦 Services Overview

### 🔴 API Service (`/api`)

**Rails 8 JSON API** providing bead catalog and inventory management.

**Key Features:**

- Bead catalog with search, filtering, and pagination
- User inventory management with custom fields
- JWT authentication
- RESTful API design
- Performance optimizations for large datasets

**Tech Stack:**

- Rails 8.0.1
- PostgreSQL
- JWT authentication
- RSpec for testing
- Docker ready

**Quick Commands:**

```bash
cd api
bundle exec rails server    # Start server
bundle exec rspec           # Run tests
rails db:migrate            # Run migrations
rails beads:status          # Check bead data status
```

### 🔵 UI Service (`/ui`)

**React TypeScript frontend** with modern tooling and responsive design.

**Key Features:**

- Responsive bead catalog browsing
- Advanced search and filtering
- Inventory management interface
- Optimized performance for large datasets
- Modern UI/UX with styled-components

**Tech Stack:**

- React 19
- TypeScript
- TanStack Query (React Query)
- Styled Components
- Vite (build tool)
- Vitest (testing)

**Quick Commands:**

```bash
cd ui
npm run dev                 # Start dev server
npm test                   # Run tests
npm run build              # Build for production
npm run format             # Format code
```

### 🟡 Crawler Service (`/crawler`)

**Python web crawler** for collecting bead data from supplier websites.

**Key Features:**

- Scrapes Fire Mountain Gems for Miyuki Delica beads
- Respects robots.txt and rate limiting
- Outputs structured JSON data
- Extensible for multiple suppliers

**Tech Stack:**

- Python 3.8+
- Scrapy framework
- JSON output format

**Quick Commands:**

```bash
cd crawler
python run_fire_mountain_gem_crawler.py   # Run crawler
python run_miyuki_directory_crawler.py    # Alternative crawler
```

## 🎯 Key Features

### Bead Catalog Management

- **Browse & Search**: Paginated catalog with search by name/code
- **Advanced Filtering**: Filter by brand, type, size, color, finish
- **Performance Optimized**: Handles 1000+ beads efficiently
- **Image Management**: Optimized loading and caching

### Inventory Tracking

- **Personal Inventory**: Track your bead collection
- **Custom Fields**: Add purchase date, location, notes, etc.
- **Flexible Data**: JSON-based custom field system
- **Bulk Operations**: Add multiple items at once

### Data Collection

- **Automated Crawling**: Regularly update bead catalog
- **Multiple Sources**: Extensible crawler architecture
- **Data Quality**: Structured import with validation

## 🔧 Development

### Running Individual Services

```bash
# API only
cd api && rails server

# UI only
cd ui && npm run dev

# Crawler only
cd crawler && python run_fire_mountain_gem_crawler.py
```

### Testing

```bash
# API tests
cd api && bundle exec rspec

# UI tests
cd ui && npm test

# Run tests in watch mode
cd ui && npm run test:watch
```

### Code Quality

```bash
# Format UI code
cd ui && npm run format

# Lint UI code
cd ui && npm run lint

# Ruby linting (if rubocop is configured)
cd api && bundle exec rubocop
```

## 📊 Performance Optimizations

The system is designed to handle large datasets efficiently:

- **API**: Database query optimization, selective field loading, caching
- **Frontend**: Virtual scrolling, image lazy loading, debounced search
- **Crawler**: Respectful rate limiting, caching, efficient parsing

See `/docs/specs/BEAD_LIST_OPTIMIZATION_SPEC.md` for detailed performance targets and implementation strategies.

## 🏗️ Architecture Decisions

### Monorepo Structure

- **Shared Development**: Single repository for all related services
- **Independent Deployment**: Each service can be deployed separately
- **Coordinated Development**: Easy to make changes across services

### Technology Choices

- **Rails API-only**: Fast JSON API with excellent ecosystem
- **React + TypeScript**: Type-safe frontend development
- **Scrapy**: Robust and respectful web crawling
- **PostgreSQL**: Reliable relational database with JSON support

### Data Flow

1. **Crawler** → JSON files
2. **Rails Import** → PostgreSQL database
3. **API** → JSON responses
4. **React UI** → User interface

## 🚀 Deployment

Each service can be deployed independently:

### API Deployment

- Docker-ready Rails application
- Environment variables for configuration
- Database migrations included

### UI Deployment

- Static build output (`npm run build`)
- Can be served from CDN or static hosting
- Environment-specific API endpoints

### Crawler Deployment

- Scheduled Python scripts
- JSON output can be processed by Rails import tasks
- Configurable via environment variables

## 🤝 Contributing

1. **Follow existing patterns**: Each service has established conventions
2. **Test your changes**: Comprehensive test suites for all services
3. **Update documentation**: Keep specs and README current
4. **Performance aware**: Consider impact on large datasets

### Code Style

- **Ruby**: Follow Rails conventions, use RSpec for tests
- **TypeScript**: Use ESLint + Prettier, comprehensive typing
- **Python**: Follow PEP 8, use type hints where helpful

## 📚 Documentation

- `/docs/specs/` - Detailed feature specifications
- `/docs/diagrams/` - Architecture and data flow diagrams
- Service READMEs - Individual service documentation
- Code comments - Inline documentation for complex logic

## 🔍 Troubleshooting

### Common Issues

**Services won't start:**

- Check that PostgreSQL is running
- Verify all dependencies are installed
- Check port conflicts (3000, 5173)

**Database issues:**

- Run `rails db:migrate` in API directory
- Check PostgreSQL connection settings
- Verify database exists

**Crawler issues:**

- Check network connectivity
- Verify Python dependencies installed
- Review robots.txt compliance

### Getting Help

1. Check service-specific README files
2. Review error logs in terminal output
3. Check issue tracker for known problems
4. Verify environment setup matches prerequisites

## 📄 License

This project is part of the Pattern Maker application suite.

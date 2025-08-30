# 🧵 Pattern Maker

A full-stack application for beading enthusiasts to catalog beads, manage inventory, and create beautiful bead patterns.

## 🎯 Overview

Pattern Maker is a modern web application that helps beading artists:

- **Browse & Search** an extensive catalog of beads from various brands
- **Manage Inventory** with personalized tracking and custom fields
- **Create Patterns** with an intuitive visual designer _(coming soon)_
- **Organize Projects** to keep track of creative ideas _(coming soon)_

## 🏗️ Architecture

This is a monorepo containing:

```
pattern-maker-mono/
├── api/          # Rails 8 API backend
├── ui/           # React TypeScript frontend
├── crawler/      # Python web scrapers
└── docs/         # Documentation & specs
```

### Technology Stack

**Backend (API)**

- **Ruby on Rails 8** - API-only application
- **PostgreSQL** - Primary database
- **JWT Authentication** - Secure user sessions
- **RSpec** - Testing framework
- **RuboCop** - Code quality

**Frontend (UI)**

- **React 18** - Component library
- **TypeScript** - Type safety
- **Styled Components** - CSS-in-JS styling
- **TanStack Query** - Data fetching & caching
- **Vite** - Build tool & dev server
- **Vitest** - Testing framework

**Data Collection (Crawler)**

- **Python** - Scrapy-based web crawlers
- **PostgreSQL** - Direct database imports
- **JSON** - Data interchange format

## 🚀 Quick Start

### Prerequisites

- **Ruby** 3.1+ with Bundler
- **Node.js** 18+ with npm
- **Python** 3.8+ with pip
- **PostgreSQL** 12+

### 1. Clone & Setup

```bash
git clone <repository-url>
cd pattern-maker-mono
```

### 2. Database Setup

```bash
cd api
bundle install
rails db:create db:migrate db:seed
```

### 3. Start Development Servers

**Option A: All at once (Recommended)**

```bash
# From root directory
overmind start -f Procfile.dev
# or with foreman: foreman start -f Procfile.dev
```

**Option B: Individual services**

```bash
# Terminal 1: API
cd api && rails server

# Terminal 2: UI
cd ui && npm install && npm run dev
```

### 4. Access the Application

- **Frontend**: http://localhost:5173
- **API**: http://localhost:3000
- **API Status**: http://localhost:3000/api/v1/status

## 📚 Detailed Setup

### API Setup

```bash
cd api
bundle install
cp .env.example .env  # Configure environment variables
rails db:create
rails db:migrate
rails db:seed
rails server
```

**Environment Variables:**

```bash
DATABASE_URL=postgresql://username:password@localhost/pattern_maker_development
JWT_SECRET=your_jwt_secret_here
RAILS_ENV=development
```

### UI Setup

```bash
cd ui
npm install
npm run dev
```

The UI will proxy API requests to `http://localhost:3000` in development.

### Crawler Setup

```bash
cd crawler
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

## 🎲 Data Collection

### Importing Bead Data

1. **Run the Miyuki crawler:**

   ```bash
   cd crawler
   source venv/bin/activate
   python run_miyuki_directory_crawler.py
   ```

2. **Data is automatically imported** to the database after crawling

3. **Check import status:**
   ```bash
   cd api
   rails console
   > Catalog::Bead.count  # Should show imported beads
   ```

## 🧪 Testing

### Run All Tests

```bash
# API Tests
cd api && rspec

# UI Tests
cd ui && npm test

# Code Quality
cd api && rubocop
cd ui && npm run lint
```

### Test Coverage

```bash
# API Coverage
cd api && rspec --format documentation

# UI Coverage
cd ui && npm run test:coverage
```

## 🌟 Features

### ✅ Current Features

- **User Authentication** - Register, login, JWT-based sessions
- **Bead Catalog** - Browse, search, and filter thousands of beads
- **Inventory Management** - Track personal bead collections
- **Responsive Design** - Works on desktop and mobile
- **Data Import** - Automated bead data collection from suppliers

### 🚧 Coming Soon

- **Pattern Designer** - Visual pattern creation tools
- **Project Management** - Save and organize beading projects
- **Sharing & Export** - Share patterns with the community
- **Advanced Search** - Color matching and size recommendations

## 📖 API Documentation

### Key Endpoints

```bash
# Authentication
POST /api/v1/auth/login
POST /api/v1/auth/register

# Catalog
GET  /api/v1/catalog/beads
GET  /api/v1/catalog/beads/:id
GET  /api/v1/catalog/bead_brands
GET  /api/v1/catalog/bead_colors

# Inventory
GET  /api/v1/inventories
POST /api/v1/inventories
GET  /api/v1/inventories/bead/:bead_id
```

Full API documentation: [`docs/api/`](docs/api/)

## 🏃‍♀️ Development

### Project Structure

```
api/
├── app/
│   ├── controllers/api/v1/     # API endpoints
│   ├── models/catalog/         # Bead catalog models
│   ├── models/                 # User & inventory models
│   └── services/               # Business logic
├── db/                         # Migrations & seeds
├── spec/                       # Tests
└── lib/spiders/               # Ruby crawlers (legacy)

ui/src/
├── components/                 # React components
├── pages/                     # Route components
├── hooks/                     # Custom React hooks
├── services/                  # API clients
├── styles/                    # Theme & styled components
└── types/                     # TypeScript definitions

crawler/
├── spiders/                   # Web crawlers
├── importers/                 # Database import scripts
└── config/                    # Crawler settings
```

### Adding New Features

1. **Backend**: Add model → controller → routes → tests
2. **Frontend**: Add types → API hooks → components → tests
3. **Update**: Documentation and tests

### Code Style

- **Ruby**: Follow RuboCop rules (`.rubocop.yml`)
- **TypeScript**: ESLint + Prettier configuration
- **Python**: PEP 8 standards

## 🚀 Deployment

### Production Build

```bash
# Build UI
cd ui && npm run build

# Prepare API
cd api && RAILS_ENV=production rails assets:precompile
```

### Docker Support

```bash
# Build containers
docker-compose build

# Run in production mode
docker-compose up -d
```

### Environment Variables

Required for production:

```bash
# API
DATABASE_URL=postgresql://...
JWT_SECRET=secure_random_string
RAILS_ENV=production
RAILS_MASTER_KEY=your_master_key

# UI
VITE_API_BASE_URL=https://your-api-domain.com
```

## 🤝 Contributing

1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/amazing-feature`
3. **Test** your changes: `npm test` and `rspec`
4. **Commit** your changes: `git commit -m 'Add amazing feature'`
5. **Push** to the branch: `git push origin feature/amazing-feature`
6. **Open** a Pull Request

### Development Guidelines

- Write tests for new features
- Follow existing code patterns
- Update documentation
- Keep commits focused and descriptive

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🐛 Troubleshooting

### Common Issues

**Database Connection Errors**

```bash
# Reset database
cd api && rails db:drop db:create db:migrate db:seed
```

**Node Module Issues**

```bash
# Clean install
cd ui && rm -rf node_modules package-lock.json && npm install
```

**CORS Issues**

- Ensure API is running on port 3000
- Check `vite.config.ts` proxy configuration

**Import Failures**

- Verify database connection in crawler config
- Check PostgreSQL permissions

### Getting Help

- 📖 [Full Documentation](docs/)
- 🐛 [Issue Tracker](issues/)
- 💬 [Discussions](discussions/)

---

**Built with ❤️ by beading enthusiasts, for beading enthusiasts**

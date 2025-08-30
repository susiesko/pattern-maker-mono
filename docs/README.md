# Pattern Maker Documentation

This directory contains comprehensive documentation for the Pattern Maker monorepo project.

## 📁 Documentation Structure

### `/analysis/`
Technical analysis and code reviews
- [`CODEBASE_ANALYSIS.md`](analysis/CODEBASE_ANALYSIS.md) - Comprehensive codebase analysis with critical issues and recommendations

### `/architecture/` 
System design and architectural decisions
- [`BEAD_PRICING_STRATEGY.md`](architecture/BEAD_PRICING_STRATEGY.md) - Pricing data acquisition strategies and implementation plans

### `/api/`
API documentation and specifications
- [`/requests/user_inventory.http`](requests/user_inventory.http) - HTTP request examples

### `/deployment/`
Deployment guides and infrastructure documentation
- [`HEROKU_DEPLOYMENT.md`](deployment/HEROKU_DEPLOYMENT.md) - Hybrid Heroku/Netlify deployment guide

### `/development/`
Development guides and best practices
- Coming soon: Development setup, coding standards, contribution guidelines

### `/diagrams/`
System diagrams and visual documentation
- [`/catalog/`](diagrams/catalog/) - Database and class diagrams for catalog system

### `/guides/`
Step-by-step implementation guides
- [`/spiders/fire_mountain_gems.md`](guides/spiders/fire_mountain_gems.md) - Web scraper implementation guide

### `/specs/`
Feature specifications and requirements
- [`BEAD_LIST_OPTIMIZATION_SPEC.md`](specs/BEAD_LIST_OPTIMIZATION_SPEC.md) - Bead catalog optimization requirements
- [`OPTIMIZATION_TIMELINE.md`](specs/OPTIMIZATION_TIMELINE.md) - Implementation timeline

## 🎯 Project Overview

Pattern Maker is a comprehensive bead catalog and inventory management system consisting of:
- **Rails API** - Backend with PostgreSQL
- **React UI** - Frontend with TypeScript and Vite  
- **Python Crawler** - Web scraping for product data

## 📋 Task Management

Tasks are tracked in [YouTrack](https://pattern-maker.youtrack.cloud) with GitHub integration for automatic commit linking.

## 🚀 Quick Start

See [`deployment/HEROKU_DEPLOYMENT.md`](deployment/HEROKU_DEPLOYMENT.md) for setup instructions.
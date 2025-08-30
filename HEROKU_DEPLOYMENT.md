# Heroku Deployment Guide

This monorepo is configured for deployment as two separate Heroku apps:

## 🔴 API Deployment (Rails)

### 1. Create and Deploy API App

```bash
# From the root directory
heroku create your-app-name-api
heroku addons:create heroku-postgresql:essential-0 --app your-app-name-api

# Deploy from api subdirectory
git subtree push --prefix=api heroku main

# Or set up automatic deploys from GitHub
```

### 2. Required Environment Variables

```bash
heroku config:set RAILS_ENV=production --app your-app-name-api
heroku config:set RAILS_SERVE_STATIC_FILES=false --app your-app-name-api
heroku config:set RAILS_LOG_TO_STDOUT=true --app your-app-name-api

# Add your JWT secret
heroku config:set JWT_SECRET_KEY="your-secret-key" --app your-app-name-api

# CORS origins (add your UI domain)
heroku config:set ALLOWED_ORIGINS="https://your-app-name-ui.herokuapp.com" --app your-app-name-api
```

### 3. Database Setup

```bash
heroku run rails db:migrate --app your-app-name-api
heroku run rails db:seed --app your-app-name-api
```

## 🔵 UI Deployment (React)

### 1. Create and Deploy UI App

```bash
# From the root directory
heroku create your-app-name-ui
heroku buildpacks:add heroku/nodejs --app your-app-name-ui
heroku buildpacks:add https://github.com/heroku/heroku-buildpack-static --app your-app-name-ui

# Deploy from ui subdirectory
git subtree push --prefix=ui heroku main
```

### 2. Required Environment Variables

Set the API URL in your UI environment:

```bash
heroku config:set VITE_API_URL="https://your-app-name-api.herokuapp.com" --app your-app-name-ui
```

Update your `ui/.env.production` file:
```
VITE_API_URL=https://your-app-name-api.herokuapp.com
```

## 🚀 Deployment Commands

### Deploy API Only
```bash
git subtree push --prefix=api heroku main
```

### Deploy UI Only
```bash
git subtree push --prefix=ui heroku-ui main
```

### Deploy Both (separate remotes)
```bash
# Add both apps as remotes
git remote add heroku-api https://git.heroku.com/your-app-name-api.git
git remote add heroku-ui https://git.heroku.com/your-app-name-ui.git

# Deploy both
git subtree push --prefix=api heroku-api main
git subtree push --prefix=ui heroku-ui main
```

## 📋 Pre-deployment Checklist

### API (Rails)
- [ ] PostgreSQL addon added
- [ ] Environment variables set
- [ ] Database migrated and seeded
- [ ] CORS configured for UI domain
- [ ] JWT secret key set

### UI (React)
- [ ] Node.js and static buildpacks added
- [ ] API URL environment variable set
- [ ] Build process works locally (`npm run build`)
- [ ] Static file routing configured

## 🔧 Configuration Files Created

### API Files
- `api/Procfile` - Heroku process configuration
- `api/app.json` - App metadata and addon requirements
- `api/config/database.yml` - Updated for DATABASE_URL

### UI Files
- `ui/static.json` - Static file server configuration
- `ui/app.json` - App metadata and buildpack configuration

## 🛠 Troubleshooting

### API Issues
- Check logs: `heroku logs --tail --app your-app-name-api`
- Database issues: Verify DATABASE_URL is set
- CORS errors: Check ALLOWED_ORIGINS environment variable

### UI Issues
- Check logs: `heroku logs --tail --app your-app-name-ui`
- Build failures: Test `npm run build` locally
- API connection: Verify VITE_API_URL is correct
- Routing issues: Check `static.json` configuration

### Common Commands
```bash
# View app info
heroku info --app your-app-name-api

# Open app in browser
heroku open --app your-app-name-api

# Run Rails console
heroku run rails console --app your-app-name-api

# View config vars
heroku config --app your-app-name-api
```
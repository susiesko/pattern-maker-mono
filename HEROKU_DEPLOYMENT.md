# Deployment Guide

This monorepo is configured for hybrid deployment:
- **API**: Heroku (Rails with PostgreSQL)  
- **UI**: Netlify (React SPA with static hosting)

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

## 🟢 UI Deployment (Netlify)

### 1. Automatic GitHub Integration

The UI deploys automatically via Netlify's GitHub integration:

1. **Connect Repository**: Link your GitHub repo to Netlify
2. **Build Settings** (configured in `netlify.toml`):
   - **Build command**: `cd ui && npm install && npm run build`
   - **Publish directory**: `ui/dist`
   - **Base directory**: `.` (root)

### 2. Environment Variables

The API URL is configured in `netlify.toml`:
```toml
[build.environment]
  VITE_API_URL = "https://pattern-maker-api-b7d4a84ca444.herokuapp.com"
```

### 3. Features
- ✅ Automatic deploys on push to main
- ✅ SPA routing with fallback to index.html
- ✅ TypeScript build with test exclusion
- ✅ Optimized static asset serving

## 🚀 Deployment Commands

### Deploy API Only
```bash
git subtree push --prefix=api heroku main
```

### Deploy UI (via Netlify)
UI deploys automatically when changes are pushed to the main branch through Netlify's GitHub integration.

### Manual Netlify Deploy
```bash
# Install Netlify CLI
npm install -g netlify-cli

# Build and deploy from ui directory
cd ui
npm run build
netlify deploy --prod --dir=dist
```

## 📋 Pre-deployment Checklist

### API (Rails)
- [ ] PostgreSQL addon added
- [ ] Environment variables set
- [ ] Database migrated and seeded
- [ ] CORS configured for UI domain
- [ ] JWT secret key set

### UI (React on Netlify)
- [ ] GitHub repository connected to Netlify
- [ ] API URL environment variable set in netlify.toml
- [ ] Build process works locally (`npm run build`)
- [ ] TypeScript compilation passes without errors

## 🔧 Configuration Files Created

### API Files
- `api/Procfile` - Heroku process configuration
- `api/app.json` - App metadata and addon requirements
- `api/config/database.yml` - Updated for DATABASE_URL

### UI Files
- `netlify.toml` - Netlify build and deployment configuration
- `ui/tsconfig.build.json` - TypeScript build configuration excluding tests

## 🛠 Troubleshooting

### API Issues
- Check logs: `heroku logs --tail --app your-app-name-api`
- Database issues: Verify DATABASE_URL is set
- CORS errors: Check ALLOWED_ORIGINS environment variable

### UI Issues (Netlify)
- Check build logs in Netlify dashboard
- Build failures: Test `npm run build` locally in ui directory
- TypeScript errors: Run `npm run type-check` in ui directory
- API connection: Verify VITE_API_URL in netlify.toml is correct
- Routing issues: Check SPA redirect configuration in netlify.toml

### Common Commands

#### API (Heroku)
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

#### UI (Netlify)
```bash
# View site info
netlify sites:list

# Open site in browser
netlify open

# View build logs
netlify logs

# Manual deploy
netlify deploy --prod --dir=ui/dist
```
ok 
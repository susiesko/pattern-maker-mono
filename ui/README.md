# Pattern Maker UI

A React application for the Pattern Maker project, built with:
- React
- TypeScript
- React Query for data fetching
- Styled Components for styling
- Vite for fast development
- Vitest for testing

## Getting Started

### Prerequisites

- Node.js (v16 or later)
- npm or yarn
- The Pattern Maker API running locally (Rails backend)

### Installation

1. Clone the repository
2. Navigate to the ui directory:
   ```
   cd pattern-maker-mono/ui
   ```
3. Install dependencies:
   ```
   npm install
   # or
   yarn
   ```

### Development

Start the development server:
```
npm run dev
# or
yarn dev
```

This will start the Vite development server, typically at http://localhost:5173.

### Building for Production

Build the application for production:
```
npm run build
# or
yarn build
```

This will create a `dist` directory with the compiled assets.

### Running Tests

Run the tests:
```
npm test
# or
yarn test
```

Run tests in watch mode:
```
npm run test:watch
# or
yarn test:watch
```

## Project Structure

- `src/` - Source code
  - `components/` - React components
  - `services/` - API and other services
  - `styles/` - Theme and styled-components types
  - `test/` - Test setup and utilities
  - `App.tsx` - Main application component
  - `main.tsx` - Application entry point

## Features

- View a paginated list of beads from the catalog
- Search for beads by name or product code
- Filter beads by various attributes
- Responsive design for desktop and mobile

## API Integration

The application connects to the Pattern Maker API. In development, API requests are proxied to the Rails backend (typically running on port 3000) to avoid CORS issues.

## Notes

- Make sure the Rails API is running before starting the client application
- The proxy configuration in `vite.config.ts` assumes the API is running on `http://localhost:3000`# React + TypeScript + Vite

This template provides a minimal setup to get React working in Vite with HMR and some ESLint rules.

Currently, two official plugins are available:

- [@vitejs/plugin-react](https://github.com/vitejs/vite-plugin-react/blob/main/packages/plugin-react/README.md) uses [Babel](https://babeljs.io/) for Fast Refresh
- [@vitejs/plugin-react-swc](https://github.com/vitejs/vite-plugin-react-swc) uses [SWC](https://swc.rs/) for Fast Refresh

## Expanding the ESLint configuration

If you are developing a production application, we recommend updating the configuration to enable type-aware lint rules:

```js
export default tseslint.config({
  extends: [
    // Remove ...tseslint.configs.recommended and replace with this
    ...tseslint.configs.recommendedTypeChecked,
    // Alternatively, use this for stricter rules
    ...tseslint.configs.strictTypeChecked,
    // Optionally, add this for stylistic rules
    ...tseslint.configs.stylisticTypeChecked,
  ],
  languageOptions: {
    // other options...
    parserOptions: {
      project: ['./tsconfig.node.json', './tsconfig.app.json'],
      tsconfigRootDir: import.meta.dirname,
    },
  },
})
```

You can also install [eslint-plugin-react-x](https://github.com/Rel1cx/eslint-react/tree/main/packages/plugins/eslint-plugin-react-x) and [eslint-plugin-react-dom](https://github.com/Rel1cx/eslint-react/tree/main/packages/plugins/eslint-plugin-react-dom) for React-specific lint rules:

```js
// eslint.config.js
import reactX from 'eslint-plugin-react-x'
import reactDom from 'eslint-plugin-react-dom'

export default tseslint.config({
  plugins: {
    // Add the react-x and react-dom plugins
    'react-x': reactX,
    'react-dom': reactDom,
  },
  rules: {
    // other rules...
    // Enable its recommended typescript rules
    ...reactX.configs['recommended-typescript'].rules,
    ...reactDom.configs.recommended.rules,
  },
})
```

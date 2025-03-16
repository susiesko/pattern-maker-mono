# Setup Instructions for Pattern Maker UI

## Install Required Dependencies

Before running the application, you **MUST** install the react-router-dom package. This is a critical dependency for the application to function properly:

```bash
# Using npm
npm install react-router-dom

# Using yarn
yarn add react-router-dom
```

Alternatively, you can update your package.json file directly by adding:
```json
"react-router-dom": "^6.22.3"
```
to the dependencies section, and then running `npm install` or `yarn`.

> **Important**: The application will not work without react-router-dom as it's used for all navigation and routing.

## Running the Application

After installing the dependencies, you can start the application:

```bash
# Using npm
npm run dev

# Using yarn
yarn dev
```

## What's New

1. **Welcome Page**: A new welcome screen has been added as the homepage
2. **Navigation Menu**: A left sidebar navigation menu has been added
3. **Routing**: React Router has been set up to navigate between pages
4. **Improved Layout**: The application now has a consistent layout across all pages
5. **Styling Approach**: Moved all styles to styled-components with GlobalStyles

## Structure

- `/src/components/WelcomePage.tsx`: The new welcome page component with animations and feature highlights
- `/src/components/Navigation.tsx`: The navigation sidebar component with icons and active state styling
- `/src/components/Layout.tsx`: The layout component that includes navigation and content
- `/src/components/ComingSoon.tsx`: A placeholder component for features that are in development
- `/src/styles/GlobalStyles.ts`: Global styles using styled-components
- `/src/App.tsx`: Updated to include routing and the new components

## Styling Approach

The application now uses styled-components exclusively for all styling:

- Component-specific styles are defined within each component file
- Global styles are defined in `/src/styles/GlobalStyles.ts` using the `createGlobalStyle` function
- No CSS files are used, making the styling approach more consistent

## Next Steps

You can further customize the welcome page and add more routes as needed. The current implementation includes:

- Home page (welcome screen)
- Beads catalog page

You can add more pages by:

1. Creating a new component
2. Adding a new route in `App.tsx`
3. Adding a new navigation link in `Navigation.tsx`
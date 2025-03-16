# Package.json Update Instructions

## Add React Router

You need to add react-router-dom to your dependencies. Update your package.json file by adding the following line to the dependencies section:

```json
"react-router-dom": "^6.22.3"
```

Your dependencies section should look something like this:

```json
"dependencies": {
  "@tanstack/react-query": "^5.67.3",
  "axios": "^1.8.3",
  "react": "^19.0.0",
  "react-dom": "^19.0.0",
  "react-router-dom": "^6.22.3",
  "styled-components": "^6.1.15"
}
```

After updating the package.json file, run one of the following commands to install the new dependency:

```bash
# Using npm
npm install

# Using yarn
yarn
```

## Why React Router is Needed

React Router is essential for this application because:

1. It enables navigation between different pages/views without refreshing the browser
2. It provides components like `BrowserRouter`, `Routes`, `Route`, and `Link` that we use throughout the application
3. It manages the application's routing state and URL synchronization
4. It allows for nested routes, which we use with the Layout component

Without React Router, the navigation menu and page transitions would not work properly.
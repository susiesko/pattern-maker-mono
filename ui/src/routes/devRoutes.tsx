import React, { Suspense } from 'react';
import { Route } from 'react-router-dom';

// Lazy load development pages
const TokenExpirationTestPage = React.lazy(() => import('../pages/local-dev/TokenExpirationTestPage'));
const EnvironmentTestPage = React.lazy(() => import('../pages/local-dev/EnvironmentTestPage'));

export const DevRoutes = () => (
  <>
    <Route 
      path="test-token-expiration" 
      element={
        <Suspense fallback={<div>Loading...</div>}>
          <TokenExpirationTestPage />
        </Suspense>
      } 
    />
    <Route 
      path="test-environment" 
      element={
        <Suspense fallback={<div>Loading...</div>}>
          <EnvironmentTestPage />
        </Suspense>
      } 
    />
  </>
); 
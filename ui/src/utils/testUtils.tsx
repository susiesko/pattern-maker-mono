import { ReactNode } from 'react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ThemeProvider } from 'styled-components';
import theme from '../styles/theme';

/**
 * Creates a wrapper component with QueryClientProvider and ThemeProvider
 * for use in tests that need these providers
 * 
 * @returns A wrapper component for tests
 */
export const createTestWrapper = () => {
  // Create a new QueryClient for each test
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: {
        // Turn off retries to make testing easier
        retry: false,
        // Don't refetch on window focus during tests
        refetchOnWindowFocus: false,
      },
    },
  });

  return ({ children }: { children: ReactNode }) => (
    <QueryClientProvider client={queryClient}>
      <ThemeProvider theme={theme}>
        {children}
      </ThemeProvider>
    </QueryClientProvider>
  );
};

/**
 * Creates an expired JWT token for testing purposes
 * This is useful for testing token expiration handling
 */
export const createExpiredToken = (): string => {
  // Create a payload that expired 1 hour ago
  const expiredTime = Math.floor(Date.now() / 1000) - 3600; // 1 hour ago
  const payload = {
    user_id: 1,
    email: 'test@example.com',
    exp: expiredTime,
    iat: expiredTime - 3600 // issued 1 hour before expiration
  };

  // Create a simple JWT structure (header.payload.signature)
  const header = btoa(JSON.stringify({ alg: 'HS256', typ: 'JWT' }));
  const payloadBase64 = btoa(JSON.stringify(payload));
  const signature = 'test-signature'; // This is just for testing

  return `${header}.${payloadBase64}.${signature}`;
};

/**
 * Creates a token that expires in a few seconds for testing
 */
export const createSoonToExpireToken = (secondsFromNow = 5): string => {
  const expirationTime = Math.floor(Date.now() / 1000) + secondsFromNow;
  const payload = {
    user_id: 1,
    email: 'test@example.com',
    exp: expirationTime,
    iat: Math.floor(Date.now() / 1000)
  };

  const header = btoa(JSON.stringify({ alg: 'HS256', typ: 'JWT' }));
  const payloadBase64 = btoa(JSON.stringify(payload));
  const signature = 'test-signature';

  return `${header}.${payloadBase64}.${signature}`;
};

/**
 * Sets up an expired token in localStorage for testing
 */
export const setupExpiredTokenForTesting = (): void => {
  const expiredToken = createExpiredToken();
  localStorage.setItem('auth_token', expiredToken);
  localStorage.setItem('user_data', JSON.stringify({
    id: '1',
    email: 'test@example.com',
    name: 'Test User'
  }));
  
  // Update API headers - using safer approach
  if (typeof window !== 'undefined') {
    // @ts-ignore - accessing axios instance for testing
    const apiInstance = (window as any).api;
    if (apiInstance?.defaults?.headers?.common) {
      apiInstance.defaults.headers.common.Authorization = `Bearer ${expiredToken}`;
    }
  }
  
  console.log('🔧 Test setup: Expired token has been set in localStorage');
  console.log('🔧 Token expires at:', new Date((Math.floor(Date.now() / 1000) - 3600) * 1000));
};

/**
 * Clears test tokens from localStorage
 */
export const clearTestTokens = (): void => {
  localStorage.removeItem('auth_token');
  localStorage.removeItem('user_data');
  
  // Clear API headers - using safer approach
  if (typeof window !== 'undefined') {
    // @ts-ignore - accessing axios instance for testing
    const apiInstance = (window as any).api;
    if (apiInstance?.defaults?.headers?.common) {
      delete apiInstance.defaults.headers.common.Authorization;
    }
  }
  
  console.log('🧹 Test cleanup: Tokens cleared from localStorage');
};

/**
 * Makes test functions available globally for browser console testing
 * Only available in development mode
 */
if (typeof window !== 'undefined' && import.meta.env.DEV) {
  // @ts-ignore - adding to window for development testing
  window.tokenExpirationTest = {
    setupExpiredToken: setupExpiredTokenForTesting,
    setupSoonToExpireToken: (seconds = 10) => {
      const token = createSoonToExpireToken(seconds);
      localStorage.setItem('auth_token', token);
      localStorage.setItem('user_data', JSON.stringify({
        id: '1',
        email: 'test@example.com',
        name: 'Test User'
      }));
      console.log(`🔧 Token set to expire in ${seconds} seconds`);
    },
    clearTokens: clearTestTokens,
    testApiCall: async () => {
      try {
        const response = await fetch('/api/v1/auth/me', {
          headers: {
            'Authorization': `Bearer ${localStorage.getItem('auth_token')}`,
            'Content-Type': 'application/json'
          }
        });
        console.log('API Response Status:', response.status);
        return response.status;
      } catch (error) {
        console.error('API Call Error:', error);
        return 'Error';
      }
    },
    checkTokenStatus: () => {
      const token = localStorage.getItem('auth_token');
      if (!token) {
        console.log('❌ No token found');
        return;
      }
      
      try {
        const payload = JSON.parse(atob(token.split('.')[1]));
        const now = Math.floor(Date.now() / 1000);
        const isExpired = payload.exp < now;
        const timeLeft = payload.exp - now;
        
        console.log('🔍 Token Status:');
        console.log('  - Expires at:', new Date(payload.exp * 1000));
        console.log('  - Is expired:', isExpired);
        console.log('  - Time left:', timeLeft > 0 ? `${timeLeft} seconds` : 'Expired');
      } catch (error) {
        console.log('❌ Invalid token format');
      }
    }
  };

  console.log('🔧 Token expiration test utilities available!');
  console.log('Available commands:');
  console.log('  - window.tokenExpirationTest.setupExpiredToken()');
  console.log('  - window.tokenExpirationTest.setupSoonToExpireToken(seconds)');
  console.log('  - window.tokenExpirationTest.clearTokens()');
  console.log('  - window.tokenExpirationTest.testApiCall()');
  console.log('  - window.tokenExpirationTest.checkTokenStatus()');
}
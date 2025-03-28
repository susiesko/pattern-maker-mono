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
    // Silence React Query errors in tests
    logger: {
      log: console.log,
      warn: console.warn,
      error: () => {},
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
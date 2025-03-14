import { render, screen } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ThemeProvider } from 'styled-components';
import BeadsList from './BeadsList';
import theme from '../styles/theme';
import { vi } from 'vitest';

// Mock the API service
vi.mock('../services/api', () => ({
  default: {
    get: vi.fn()
  }
}));

// Create a wrapper with QueryClientProvider and ThemeProvider
const createWrapper = () => {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: {
        retry: false,
      },
    },
  });
  
  return ({ children }: { children: React.ReactNode }) => (
    <QueryClientProvider client={queryClient}>
      <ThemeProvider theme={theme}>
        {children}
      </ThemeProvider>
    </QueryClientProvider>
  );
};

describe('BeadsList', () => {
  it('shows loading state initially', () => {
    render(<BeadsList />, { wrapper: createWrapper() });
    expect(screen.getByText(/loading beads/i)).toBeInTheDocument();
  });
  
  // Add more tests as needed
});
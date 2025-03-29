import { render, screen } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ThemeProvider } from 'styled-components';
import { MemoryRouter } from 'react-router-dom';
import BeadsList from './BeadsList.tsx';
import theme from '../../styles/theme.ts';
import { vi } from 'vitest';
import useBeadsQuery from '../../hooks/queries/useBeadsQuery';

// Mock the hooks
vi.mock('../../hooks/queries/useBeadsQuery');

// Mock the API service
vi.mock('../../services/api', () => ({
  default: {
    get: vi.fn(),
  },
}));

// Create a wrapper with QueryClientProvider, ThemeProvider, and MemoryRouter
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
        <MemoryRouter>{children}</MemoryRouter>
      </ThemeProvider>
    </QueryClientProvider>
  );
};

describe('BeadsList', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('shows loading state initially', () => {
    // Mock the hook to return loading state
    (useBeadsQuery as any).mockReturnValue({
      isLoading: true,
      error: null,
      data: null,
    });

    render(<BeadsList />, { wrapper: createWrapper() });
    expect(screen.getByText(/loading beads/i)).toBeInTheDocument();
  });

  it('shows error message when there is an error', () => {
    // Mock the hook to return error state
    (useBeadsQuery as any).mockReturnValue({
      isLoading: false,
      error: new Error('Test error'),
      data: null,
    });

    render(<BeadsList />, { wrapper: createWrapper() });
    expect(screen.getByText(/error loading beads/i)).toBeInTheDocument();
  });

  it('renders beads when data is loaded', () => {
    // Mock the hook to return data
    (useBeadsQuery as any).mockReturnValue({
      isLoading: false,
      error: null,
      data: [
        {
          id: 1,
          name: 'Test Bead',
          brand_product_code: 'TB-123',
          image: '',
          metadata: {},
          created_at: '2023-01-01T00:00:00Z',
          updated_at: '2023-01-01T00:00:00Z',
          brand: { id: 1, name: 'Test Brand', website: '' },
          size: { id: 1, size: '11/0' },
          type: { id: 1, name: 'Seed' },
          colors: [{ id: 1, name: 'Red' }],
          finishes: [{ id: 1, name: 'Matte' }],
        },
      ],
    });

    render(<BeadsList />, { wrapper: createWrapper() });
    expect(screen.getByText('Test Bead')).toBeInTheDocument();
    expect(screen.getByText('TB-123')).toBeInTheDocument();
    expect(screen.getByText('Test Brand')).toBeInTheDocument();
    expect(screen.getByText('Seed - 11/0')).toBeInTheDocument();
    expect(screen.getByText('Red')).toBeInTheDocument();
    expect(screen.getByText('Matte')).toBeInTheDocument();
  });
});

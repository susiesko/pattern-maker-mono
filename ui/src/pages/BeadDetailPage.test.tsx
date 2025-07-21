import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { BrowserRouter } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ThemeProvider } from 'styled-components';
import { vi } from 'vitest';
import BeadDetailPage from './BeadDetailPage';
import { useBeadQuery } from '../hooks/queries/useBeadQuery';
import theme from '../styles/theme';

// Mock the hooks
vi.mock('../hooks/queries/useBeadQuery');
vi.mock('react-router-dom', async () => {
  const actual = await vi.importActual('react-router-dom');
  return {
    ...actual,
    useParams: () => ({ id: '123' }),
    useNavigate: () => vi.fn(),
  };
});

const mockUseBeadQuery = useBeadQuery as any;

const createWrapper = () => {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: { retry: false },
      mutations: { retry: false },
    },
  });

  return ({ children }: { children: React.ReactNode }) => (
    <QueryClientProvider client={queryClient}>
      <ThemeProvider theme={theme}>
        <BrowserRouter>
          {children}
        </BrowserRouter>
      </ThemeProvider>
    </QueryClientProvider>
  );
};

const mockBead = {
  id: 123,
  name: 'Test Bead',
  brand: { id: 1, name: 'Test Brand' },
  brand_product_code: 'TB001',
  shape: 'Round',
  size: '8/0',
  color_group: 'Blue',
  finish: 'Matte',
  glass_group: 'Transparent',
  dyed: 'No',
  galvanized: 'No',
  plating: 'None',
  image: 'test-bead.jpg',
  user_inventory: null,
};

const mockBeadWithInventory = {
  ...mockBead,
  user_inventory: {
    id: 456,
    quantity: 25.5,
    quantity_unit: 'grams',
  },
};

describe('BeadDetailPage', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('renders loading state', () => {
    mockUseBeadQuery.mockReturnValue({
      data: null,
      isLoading: true,
      error: null,
    });

    render(<BeadDetailPage />, { wrapper: createWrapper() });

    expect(screen.getByText('Loading bead details...')).toBeInTheDocument();
  });

  it('renders error state', () => {
    mockUseBeadQuery.mockReturnValue({
      data: null,
      isLoading: false,
      error: new Error('Failed to load'),
    });

    render(<BeadDetailPage />, { wrapper: createWrapper() });

    expect(screen.getByText('Failed to load bead details. Please try again.')).toBeInTheDocument();
  });

  it('renders bead details correctly', () => {
    mockUseBeadQuery.mockReturnValue({
      data: mockBead,
      isLoading: false,
      error: null,
    });

    render(<BeadDetailPage />, { wrapper: createWrapper() });

    expect(screen.getByText('Test Bead')).toBeInTheDocument();
    expect(screen.getByText('Test Brand')).toBeInTheDocument();
    expect(screen.getByText('Product Code: TB001')).toBeInTheDocument();
    expect(screen.getByText('Round')).toBeInTheDocument();
    expect(screen.getByText('8/0')).toBeInTheDocument();
    expect(screen.getByText('Blue')).toBeInTheDocument();
    expect(screen.getByText('Matte')).toBeInTheDocument();
    expect(screen.getByText('Transparent')).toBeInTheDocument();
  });

  it('shows Add to Inventory button when user has no inventory', () => {
    mockUseBeadQuery.mockReturnValue({
      data: mockBead,
      isLoading: false,
      error: null,
    });

    render(<BeadDetailPage />, { wrapper: createWrapper() });

    expect(screen.getByText('Add to Inventory')).toBeInTheDocument();
  });

  it('shows Add to Inventory button even when user has inventory (modal will handle update)', () => {
    mockUseBeadQuery.mockReturnValue({
      data: mockBeadWithInventory,
      isLoading: false,
      error: null,
    });

    render(<BeadDetailPage />, { wrapper: createWrapper() });

    expect(screen.getByText('Add to Inventory')).toBeInTheDocument();
  });

  it('opens Add to Inventory modal when button is clicked', async () => {
    mockUseBeadQuery.mockReturnValue({
      data: mockBead,
      isLoading: false,
      error: null,
    });

    render(<BeadDetailPage />, { wrapper: createWrapper() });

    const addButton = screen.getByText('Add to Inventory');
    fireEvent.click(addButton);

    await waitFor(() => {
      expect(screen.getByText('Quantity *')).toBeInTheDocument();
    });
  });

  it('displays image when available', () => {
    mockUseBeadQuery.mockReturnValue({
      data: mockBead,
      isLoading: false,
      error: null,
    });

    render(<BeadDetailPage />, { wrapper: createWrapper() });

    const image = screen.getByAltText('Test Bead');
    expect(image).toBeInTheDocument();
    expect(image).toHaveAttribute('src', '/bead-images/test-bead.jpg');
  });

  it('displays placeholder when no image available', () => {
    const beadWithoutImage = { ...mockBead, image: null };
    mockUseBeadQuery.mockReturnValue({
      data: beadWithoutImage,
      isLoading: false,
      error: null,
    });

    render(<BeadDetailPage />, { wrapper: createWrapper() });

    expect(screen.getByText('No Image Available')).toBeInTheDocument();
  });

  it('handles missing optional fields gracefully', () => {
    const minimalBead = {
      id: 123,
      name: 'Minimal Bead',
      brand: { id: 1, name: 'Test Brand' },
      user_inventory: null,
    };

    mockUseBeadQuery.mockReturnValue({
      data: minimalBead,
      isLoading: false,
      error: null,
    });

    render(<BeadDetailPage />, { wrapper: createWrapper() });

    expect(screen.getByText('Minimal Bead')).toBeInTheDocument();
    expect(screen.getByText('Test Brand')).toBeInTheDocument();
    const notSpecifiedElements = screen.getAllByText('Not specified');
    expect(notSpecifiedElements).toHaveLength(2); // shape and size
  });
}); 
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { vi } from 'vitest';
import { MemoryRouter } from 'react-router-dom';
import BeadsListPage from './BeadsListPage';
import { usePaginatedBeadsQuery } from '../hooks/queries/usePaginatedBeadsQuery';
import { createTestWrapper } from '../test/testUtils';

// Mock the hooks and components
vi.mock('../hooks/queries/usePaginatedBeadsQuery');
vi.mock('../components/catalog', () => ({
  BeadCard: ({ bead, onEdit, onView }: any) => (
    <div data-testid={`bead-card-${bead.id}`}>
      <span>{bead.name}</span>
      <button onClick={() => onEdit(bead.id)}>Edit</button>
      <button onClick={() => onView(bead.id)}>View</button>
    </div>
  ),
  BeadFilters: ({ onChange }: any) => (
    <div data-testid="bead-filters">
      <button onClick={() => onChange({ brandId: '1' })}>Filter by Brand</button>
      <button onClick={() => onChange({
        brandId: '', typeId: '', sizeId: '', colorId: '', finishId: '', search: ''
      })}>Clear Filters</button>
    </div>
  ),
  BeadSearch: ({ onChange, value }: any) => (
    <input
      data-testid="bead-search"
      value={value}
      onChange={(e) => onChange(e.target.value)}
      placeholder="Search beads..."
    />
  ),
  BeadSort: ({ onChange, sort }: any) => (
    <div data-testid="bead-sort">
      <button onClick={() => onChange({ field: 'name', direction: 'asc' })}>
        Sort by Name
      </button>
    </div>
  ),
}));

vi.mock('../components/ui', () => ({
  LoadingSpinner: ({ message }: { message: string }) => (
    <div data-testid="loading-spinner">{message}</div>
  ),
  ErrorMessage: ({ message, onRetry }: any) => (
    <div data-testid="error-message">
      <span>{message}</span>
      {onRetry && <button onClick={onRetry}>Retry</button>}
    </div>
  ),
  EmptyState: ({ title, message, actionLabel, onAction }: any) => (
    <div data-testid="empty-state">
      <h2>{title}</h2>
      <p>{message}</p>
      {actionLabel && <button onClick={onAction}>{actionLabel}</button>}
    </div>
  ),
}));

vi.mock('../components/Pagination', () => ({
  default: ({ currentPage, totalPages, onPageChange, hasMore }: any) => (
    <div data-testid="pagination">
      <button 
        onClick={() => onPageChange(currentPage - 1)}
        disabled={currentPage === 1}
      >
        Previous
      </button>
      <span>Page {currentPage} of {totalPages}</span>
      <button 
        onClick={() => onPageChange(currentPage + 1)}
        disabled={!hasMore}
      >
        Next
      </button>
    </div>
  ),
}));

// Mock navigate
const mockNavigate = vi.fn();
vi.mock('react-router-dom', async () => {
  const actual = await vi.importActual('react-router-dom');
  return {
    ...actual,
    useNavigate: () => mockNavigate,
  };
});

const mockUsePaginatedBeadsQuery = vi.mocked(usePaginatedBeadsQuery);

// Sample test data
const sampleBeads = [
  {
    id: 1,
    name: 'Test Bead 1',
    brand_product_code: 'TB001',
    image: 'bead1.jpg',
    metadata: {},
    created_at: '2023-01-01T00:00:00Z',
    updated_at: '2023-01-01T00:00:00Z',
    brand: { id: 1, name: 'Test Brand', website: 'https://test.com' },
    size: { id: 1, size: '11/0' },
    type: { id: 1, name: 'Seed' },
    colors: [{ id: 1, name: 'Red' }],
    finishes: [{ id: 1, name: 'Matte' }],
  },
  {
    id: 2,
    name: 'Test Bead 2',
    brand_product_code: 'TB002',
    image: 'bead2.jpg',
    metadata: {},
    created_at: '2023-01-02T00:00:00Z',
    updated_at: '2023-01-02T00:00:00Z',
    brand: { id: 1, name: 'Test Brand', website: 'https://test.com' },
    size: { id: 1, size: '11/0' },
    type: { id: 1, name: 'Seed' },
    colors: [{ id: 2, name: 'Blue' }],
    finishes: [{ id: 2, name: 'Glossy' }],
  },
];

const defaultQueryResult = {
  data: {
    data: sampleBeads,
    pagination: {
      current_page: 1,
      per_page: 24,
      total_count: 100,
      total_pages: 5,
      has_more: true,
      has_previous: false,
    },
  },
  isLoading: false,
  error: null,
  refetch: vi.fn(),
  // Add required React Query properties
  isError: false,
  isPending: false,
  isLoadingError: false,
  isRefetchError: false,
  isStale: false,
  isSuccess: true,
  status: 'success' as const,
  fetchStatus: 'idle' as const,
  dataUpdatedAt: Date.now(),
  errorUpdatedAt: 0,
  failureCount: 0,
  failureReason: null,
  errorUpdateCount: 0,
  isFetched: true,
  isFetchedAfterMount: true,
  isFetching: false,
  isInitialLoading: false,
  isPlaceholderData: false,
  isRefetching: false,
  promise: Promise.resolve(),
} as any;

describe('BeadsListPage', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    mockUsePaginatedBeadsQuery.mockReturnValue(defaultQueryResult);
  });

  const renderWithRouter = (initialEntries = ['/beads']) => {
    return render(
      <MemoryRouter initialEntries={initialEntries}>
        <BeadsListPage />
      </MemoryRouter>,
      { wrapper: createTestWrapper() }
    );
  };

  describe('Loading State', () => {
    it('displays loading spinner when data is loading', () => {
      mockUsePaginatedBeadsQuery.mockReturnValue({
        ...defaultQueryResult,
        isLoading: true,
        data: undefined,
      });

      renderWithRouter();

      expect(screen.getByTestId('loading-spinner')).toBeInTheDocument();
      expect(screen.getByText('Loading beads...')).toBeInTheDocument();
    });
  });

  describe('Error State', () => {
    it('displays error message when there is an error', () => {
      const mockRefetch = vi.fn();
      mockUsePaginatedBeadsQuery.mockReturnValue({
        ...defaultQueryResult,
        error: new Error('Failed to fetch'),
        data: undefined,
        refetch: mockRefetch,
      });

      renderWithRouter();

      expect(screen.getByTestId('error-message')).toBeInTheDocument();
      expect(screen.getByText('Failed to load beads. Please try again.')).toBeInTheDocument();

      const retryButton = screen.getByText('Retry');
      fireEvent.click(retryButton);
      expect(mockRefetch).toHaveBeenCalledTimes(1);
    });
  });

  describe('Empty State', () => {
    it('displays empty state when no beads are available', () => {
      mockUsePaginatedBeadsQuery.mockReturnValue({
        ...defaultQueryResult,
        data: {
          data: [],
          pagination: {
            current_page: 1,
            per_page: 24,
            total_count: 0,
            total_pages: 0,
            has_more: false,
            has_previous: false,
          },
        },
      });

      renderWithRouter();

      expect(screen.getByTestId('empty-state')).toBeInTheDocument();
      expect(screen.getByText('No beads yet')).toBeInTheDocument();
      expect(screen.getByText('Get started by adding your first bead to the catalog.')).toBeInTheDocument();
    });

    it('displays filtered empty state when no beads match filters', async () => {
      mockUsePaginatedBeadsQuery.mockReturnValue({
        ...defaultQueryResult,
        data: {
          data: [],
          pagination: {
            current_page: 1,
            per_page: 24,
            total_count: 0,
            total_pages: 0,
            has_more: false,
            has_previous: false,
          },
        },
      });

      renderWithRouter();

      // Simulate applying a filter
      const filterButton = screen.getByText('Filter by Brand');
      fireEvent.click(filterButton);

      await waitFor(() => {
        expect(screen.getByText('No beads found')).toBeInTheDocument();
        expect(screen.getByText("Try adjusting your filters to find what you're looking for.")).toBeInTheDocument();
      });
    });
  });

  describe('Success State', () => {
    it('displays beads when data is loaded successfully', () => {
      renderWithRouter();

      expect(screen.getByText('Bead Catalog')).toBeInTheDocument();
      expect(screen.getByText('2 beads')).toBeInTheDocument();
      expect(screen.getByTestId('bead-card-1')).toBeInTheDocument();
      expect(screen.getByTestId('bead-card-2')).toBeInTheDocument();
    });

    it('displays singular form when only one bead', () => {
      mockUsePaginatedBeadsQuery.mockReturnValue({
        ...defaultQueryResult,
        data: {
          data: [sampleBeads[0]],
          pagination: {
            current_page: 1,
            per_page: 24,
            total_count: 1,
            total_pages: 1,
            has_more: false,
            has_previous: false,
          },
        },
      });

      renderWithRouter();

      expect(screen.getByText('1 bead')).toBeInTheDocument();
    });
  });

  describe('Navigation', () => {
    it('navigates to add bead page when Add New Bead button is clicked', () => {
      renderWithRouter();

      const addButton = screen.getByText('Add New Bead');
      fireEvent.click(addButton);

      expect(mockNavigate).toHaveBeenCalledWith('/beads/add');
    });

    it('navigates to edit page when bead edit is triggered', () => {
      renderWithRouter();

      const editButton = screen.getAllByText('Edit')[0];
      fireEvent.click(editButton);

      expect(mockNavigate).toHaveBeenCalledWith('/beads/edit/1');
    });

    it('navigates to view page when bead view is triggered', () => {
      renderWithRouter();

      const viewButton = screen.getAllByText('View')[0];
      fireEvent.click(viewButton);

      expect(mockNavigate).toHaveBeenCalledWith('/beads/1');
    });
  });

  describe('Search and Filtering', () => {
    it('updates search filter when search input changes', async () => {
      renderWithRouter();

      const searchInput = screen.getByTestId('bead-search');
      fireEvent.change(searchInput, { target: { value: 'test search' } });

      await waitFor(() => {
        expect(mockUsePaginatedBeadsQuery).toHaveBeenCalledWith(
          expect.objectContaining({
            search: 'test search',
          })
        );
      });
    });

    it('updates filters when filter is applied', async () => {
      renderWithRouter();

      const filterButton = screen.getByText('Filter by Brand');
      fireEvent.click(filterButton);

              await waitFor(() => {
          expect(mockUsePaginatedBeadsQuery).toHaveBeenCalledWith(
            expect.objectContaining({
              brand_id: 1,
            })
          );
        });
    });

    it('clears filters when clear filters is clicked', async () => {
      renderWithRouter();

      // First apply a filter
      const filterButton = screen.getByText('Filter by Brand');
      fireEvent.click(filterButton);

      // Then clear filters
      const clearButton = screen.getByText('Clear Filters');
      fireEvent.click(clearButton);

              await waitFor(() => {
          expect(mockUsePaginatedBeadsQuery).toHaveBeenCalledWith(
            expect.objectContaining({
              search: undefined,
              brand_id: undefined,
              type_id: undefined,
              size_id: undefined,
              color_id: undefined,
              finish_id: undefined,
            })
          );
        });
    });

    it('displays filtered count indicator when filters are active', async () => {
      renderWithRouter();

      const filterButton = screen.getByText('Filter by Brand');
      fireEvent.click(filterButton);

      await waitFor(() => {
        expect(screen.getByText('2 beads (filtered)')).toBeInTheDocument();
      });
    });
  });

  describe('Sorting', () => {
    it('updates sort when sort option changes', async () => {
      renderWithRouter();

      const sortButton = screen.getByText('Sort by Name');
      fireEvent.click(sortButton);

              await waitFor(() => {
          expect(mockUsePaginatedBeadsQuery).toHaveBeenCalledWith(
            expect.objectContaining({
              sort_by: 'name',
              direction: 'asc',
            })
          );
        });
    });
  });

  describe('Pagination', () => {
    it('displays pagination component when data is available', () => {
      renderWithRouter();

      expect(screen.getByTestId('pagination')).toBeInTheDocument();
    });

    it('resets to first page when filters change', async () => {
      renderWithRouter();

      const filterButton = screen.getByText('Filter by Brand');
      fireEvent.click(filterButton);

      await waitFor(() => {
        expect(mockUsePaginatedBeadsQuery).toHaveBeenCalledWith(
          expect.objectContaining({
            per_page: 24,
          })
        );
      });
    });
  });
}); 
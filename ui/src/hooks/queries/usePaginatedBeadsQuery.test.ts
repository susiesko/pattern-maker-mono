import React from 'react';
import { renderHook, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { usePaginatedBeadsQuery } from './usePaginatedBeadsQuery';
import * as queryUtils from '../../services/queryUtils';

// Mock the queryUtils module
vi.mock('../../services/queryUtils');
const mockFetchPaginatedData = vi.mocked(queryUtils.fetchPaginatedData);

// Helper to create wrapper with QueryClient
const createWrapper = () => {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: {
        retry: false,
      },
    },
  });

  return ({ children }: { children: React.ReactNode }) => QueryClientProvider({ client: queryClient, children });
};

describe('usePaginatedBeadsQuery', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('calls fetchPaginatedData with correct endpoint and filters', async () => {
    const mockResponse = {
      data: [],
      pagination: { 
        current_page: 1,
        per_page: 10,
        total_count: 0,
        total_pages: 0,
        has_more: false,
        has_previous: false
      }
    };

    mockFetchPaginatedData.mockResolvedValue(mockResponse);

    const filters = {
      per_page: 10,
      sort_by: 'name' as const,
      direction: 'asc' as const,
      search: 'test'
    };

    renderHook(() => usePaginatedBeadsQuery(filters), {
      wrapper: createWrapper(),
    });

    await waitFor(() => {
      expect(mockFetchPaginatedData).toHaveBeenCalledWith(
        'catalog/beads',
        {
          per_page: '10',
          sort_by: 'name',
          direction: 'asc',
          search: 'test'
        }
      );
    });
  });

  it('filters out undefined and empty values', async () => {
    const mockResponse = {
      data: [],
      pagination: { 
        current_page: 1,
        per_page: 20,
        total_count: 0,
        total_pages: 0,
        has_more: false,
        has_previous: false
      }
    };

    mockFetchPaginatedData.mockResolvedValue(mockResponse);

    const filters = {
      per_page: 20,
      brand_id: undefined,
      search: '',
      sort_by: 'id' as const
    };

    renderHook(() => usePaginatedBeadsQuery(filters), {
      wrapper: createWrapper(),
    });

    await waitFor(() => {
      expect(mockFetchPaginatedData).toHaveBeenCalledWith(
        'catalog/beads',
        {
          per_page: '20',
          sort_by: 'id'
        }
      );
    });
  });

  it('converts numeric filters to strings', async () => {
    const mockResponse = {
      data: [],
      pagination: { 
        current_page: 1,
        per_page: 20,
        total_count: 0,
        total_pages: 0,
        has_more: false,
        has_previous: false
      }
    };

    mockFetchPaginatedData.mockResolvedValue(mockResponse);

    const filters = {
      brand_id: 123,
      color_id: 456,
      page: 2
    };

    renderHook(() => usePaginatedBeadsQuery(filters), {
      wrapper: createWrapper(),
    });

    await waitFor(() => {
      expect(mockFetchPaginatedData).toHaveBeenCalledWith(
        'catalog/beads',
        {
          brand_id: '123',
          color_id: '456',
          page: '2'
        }
      );
    });
  });

  it('returns query result with correct structure', async () => {
    const mockBeads = [
      { id: 1, name: 'Test Bead', brand_product_code: 'TB-001' }
    ];

    const mockResponse = {
      data: mockBeads,
      pagination: { 
        current_page: 1,
        per_page: 20,
        total_count: 1,
        total_pages: 1,
        has_more: false,
        has_previous: false
      }
    };

    mockFetchPaginatedData.mockResolvedValue(mockResponse);

    const { result } = renderHook(() => usePaginatedBeadsQuery(), {
      wrapper: createWrapper(),
    });

    await waitFor(() => {
      expect(result.current.isSuccess).toBe(true);
    });

    expect(result.current.data).toEqual(mockResponse);
  });
}); 
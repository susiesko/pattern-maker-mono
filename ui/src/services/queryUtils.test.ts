import { describe, it, expect, vi, beforeEach } from 'vitest';
import { fetchPaginatedData } from './queryUtils';
import api from './api';

// Mock the api module
vi.mock('./api');
const mockApi = vi.mocked(api);

describe('fetchPaginatedData', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('makes correct API call with filters', async () => {
    const mockResponse = {
      data: {
        data: [{ id: 1, name: 'Test' }],
        pagination: { has_more: false, next_cursor: null, limit: 20 }
      }
    };

    mockApi.get.mockResolvedValue(mockResponse);

    const filters = {
      limit: '20',
      sort_by: 'name',
      search: 'test'
    };

    await fetchPaginatedData('catalog/beads', filters);

    expect(mockApi.get).toHaveBeenCalledWith('/catalog/beads?limit=20&sort_by=name&search=test');
  });

  it('handles endpoint with leading slash', async () => {
    const mockResponse = {
      data: {
        data: [],
        pagination: { has_more: false, next_cursor: null, limit: 20 }
      }
    };

    mockApi.get.mockResolvedValue(mockResponse);

    await fetchPaginatedData('/catalog/beads');

    expect(mockApi.get).toHaveBeenCalledWith('/catalog/beads');
  });

  it('filters out empty values from filters', async () => {
    const mockResponse = {
      data: {
        data: [],
        pagination: { has_more: false, next_cursor: null, limit: 20 }
      }
    };

    mockApi.get.mockResolvedValue(mockResponse);

    const filters = {
      limit: '20',
      search: '',
      brand_id: null,
      undefined_param: undefined
    };

    await fetchPaginatedData('catalog/beads', filters);

    expect(mockApi.get).toHaveBeenCalledWith('/catalog/beads?limit=20');
  });

  it('returns data and pagination info', async () => {
    const mockData = [{ id: 1, name: 'Bead 1' }];
    const mockPagination = { has_more: true, next_cursor: 'abc', limit: 20 };

    const mockResponse = {
      data: {
        data: mockData,
        pagination: mockPagination
      }
    };

    mockApi.get.mockResolvedValue(mockResponse);

    const result = await fetchPaginatedData('catalog/beads');

    expect(result).toEqual({
      data: mockData,
      pagination: mockPagination
    });
  });

  it('throws error when no data property', async () => {
    mockApi.get.mockResolvedValue({ data: null });

    await expect(fetchPaginatedData('catalog/beads')).rejects.toThrow(
      'No data returned from endpoint: catalog/beads'
    );
  });

  it('throws error when no data.data property', async () => {
    mockApi.get.mockResolvedValue({ data: {} });

    await expect(fetchPaginatedData('catalog/beads')).rejects.toThrow(
      "Response does not contain the 'data' property"
    );
  });

  it('throws error when no pagination property', async () => {
    mockApi.get.mockResolvedValue({
      data: {
        data: []
      }
    });

    await expect(fetchPaginatedData('catalog/beads')).rejects.toThrow(
      "Response does not contain the 'pagination' property"
    );
  });

  it('logs and rethrows API errors', async () => {
    const consoleErrorSpy = vi.spyOn(console, 'error').mockImplementation(() => { });
    const apiError = new Error('API Error');

    mockApi.get.mockRejectedValue(apiError);

    await expect(fetchPaginatedData('catalog/beads')).rejects.toThrow('API Error');

    expect(consoleErrorSpy).toHaveBeenCalledWith(
      'Error fetching paginated data from catalog/beads:',
      apiError
    );

    consoleErrorSpy.mockRestore();
  });
}); 
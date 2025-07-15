import api from './api';
import { PaginatedResponse } from '../types/api';

/**
 * Generic fetch function for API queries that automatically extracts the data
 * from the response.
 *
 * @param endpoint - API endpoint to fetch from (without leading slash)
 * @param filters - Optional query parameters as key-value pairs
 * @returns The response data
 */
export async function fetchData<T>(
  endpoint: string,
  filters: Record<string, string> = {}
): Promise<T> {
  // Remove any leading slash to ensure consistent formatting
  const cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;

  // Build query string from filters, filtering out empty values
  const params = new URLSearchParams();
  Object.entries(filters).forEach(([key, value]) => {
    if (value !== undefined && value !== null && value !== '') {
      params.append(key, value);
    }
  });

  const queryString = params.toString() ? `?${params}` : '';

  try {
    const response = await api.get<{ data: T }>(`/${cleanEndpoint}${queryString}`);

    // Check if the response has data
    if (!response.data) {
      throw new Error(`No data returned from endpoint: ${cleanEndpoint}`);
    }

    if (!response.data.data) {
      throw new Error(`Response does not contain the 'data' property`);
    }

    return response.data.data;
  } catch (error) {
    // Log the error but rethrow to be handled by React Query
    console.error(`Error fetching data from ${cleanEndpoint}:`, error);
    throw error;
  }
}

/**
 * Paginated fetch function for API queries that returns both data and pagination info
 *
 * @param endpoint - API endpoint to fetch from (without leading slash)
 * @param filters - Optional query parameters as key-value pairs
 * @returns The response data with pagination information
 */
export async function fetchPaginatedData<T>(
  endpoint: string,
  filters: Record<string, string | number> = {}
): Promise<PaginatedResponse<T>> {
  // Remove any leading slash to ensure consistent formatting
  const cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;

  // Build query string from filters, filtering out empty values
  const params = new URLSearchParams();
  Object.entries(filters).forEach(([key, value]) => {
    if (value !== undefined && value !== null && value !== '') {
      params.append(key, String(value));
    }
  });

  const queryString = params.toString() ? `?${params}` : '';

  try {
    const response = await api.get<{ data: T[]; pagination: any }>(`/${cleanEndpoint}${queryString}`);

    // Check if the response has data
    if (!response.data) {
      throw new Error(`No data returned from endpoint: ${cleanEndpoint}`);
    }

    if (!response.data.data) {
      throw new Error(`Response does not contain the 'data' property`);
    }

    if (!response.data.pagination) {
      throw new Error(`Response does not contain the 'pagination' property`);
    }

    return {
      data: response.data.data,
      pagination: response.data.pagination
    };
  } catch (error) {
    // Log the error but rethrow to be handled by React Query
    console.error(`Error fetching paginated data from ${cleanEndpoint}:`, error);
    throw error;
  }
}
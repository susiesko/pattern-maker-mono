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

/**
 * Generic POST function for creating resources
 *
 * @param endpoint - API endpoint (without leading slash)
 * @param data - Data to send in the request body
 * @returns The response data
 */
export async function postData<T>(
  endpoint: string,
  data: any
): Promise<T> {
  const cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;

  try {
    const response = await api.post<T>(`/${cleanEndpoint}`, data);
    return response.data;
  } catch (error) {
    console.error(`Error posting data to ${cleanEndpoint}:`, error);
    throw error;
  }
}

/**
 * Generic PUT function for updating resources
 *
 * @param endpoint - API endpoint (without leading slash)
 * @param data - Data to send in the request body
 * @returns The response data
 */
export async function putData<T>(
  endpoint: string,
  data: any
): Promise<T> {
  const cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;

  try {
    const response = await api.put<T>(`/${cleanEndpoint}`, data);
    return response.data;
  } catch (error) {
    console.error(`Error putting data to ${cleanEndpoint}:`, error);
    throw error;
  }
}

/**
 * Generic DELETE function for removing resources
 *
 * @param endpoint - API endpoint (without leading slash)
 * @returns The response data
 */
export async function deleteData<T = void>(
  endpoint: string
): Promise<T> {
  const cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;

  try {
    const response = await api.delete<T>(`/${cleanEndpoint}`);
    return response.data;
  } catch (error) {
    console.error(`Error deleting data from ${cleanEndpoint}:`, error);
    throw error;
  }
}
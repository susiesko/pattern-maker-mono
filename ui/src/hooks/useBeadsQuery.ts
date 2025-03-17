import { useQuery } from '@tanstack/react-query';
import api from '../services/api';
import { BeadsResponse } from '../types/beads';

// Re-export types for convenience
export * from '../types/beads';

// Fetch beads from the API
const fetchBeads = async (page = 1, filters: Record<string, string> = {}) => {
  // Build query parameters
  const params = new URLSearchParams({ page: page.toString(), ...filters });
  
  // Use our API service
  const response = await api.get<BeadsResponse>(`/catalog/beads?${params}`);
  return response.data;
};

/**
 * Custom hook for fetching beads with pagination and filtering
 * 
 * @param page - The current page number
 * @param filters - Object containing filter parameters
 * @returns Query result with data, loading state, and error
 */
export const useBeadsQuery = (page: number, filters: Record<string, string> = {}) => {
  return useQuery({
    queryKey: ['beads', page, filters],
    queryFn: () => fetchBeads(page, filters),
  });
};

export default useBeadsQuery;
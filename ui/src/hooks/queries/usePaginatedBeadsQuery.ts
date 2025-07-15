import { useQuery } from '@tanstack/react-query';
import { fetchPaginatedData } from '../../services/queryUtils';
import { Bead } from '../../types/beads';

export interface BeadFilters {
  // Pagination
  page?: number;
  per_page?: number;

  // Sorting
  sort_by?: 'id' | 'name' | 'product_code' | 'created_at';
  direction?: 'asc' | 'desc';

  // Filtering
  brand_id?: number;
  type_id?: number;
  size_id?: number;
  color_id?: number;
  finish_id?: number;
  search?: string;
}

/**
 * Custom hook for fetching paginated beads with sorting and filtering
 *
 * @param filters - Object containing filter, sort, and pagination parameters
 * @returns Query result with beads data, pagination info, loading state, and error
 */
export const usePaginatedBeadsQuery = (filters: BeadFilters = {}) => {
  // Convert filters to string values for API
  const apiFilters = Object.entries(filters).reduce((acc, [key, value]) => {
    if (value !== undefined && value !== null && value !== '') {
      acc[key] = String(value);
    }
    return acc;
  }, {} as Record<string, string>);

  return useQuery({
    queryKey: ['beads', 'paginated', filters],
    queryFn: () => fetchPaginatedData<Bead>('catalog/beads', apiFilters),
    // Keep previous data while fetching new page
    placeholderData: (previousData) => previousData,
    // Refetch when filters change
    staleTime: 5 * 60 * 1000, // 5 minutes
  });
};

export default usePaginatedBeadsQuery; 
// noinspection ES6PreferShortImport

import { useQuery } from '@tanstack/react-query';
import { fetchData } from '../../services/queryUtils';

/**
 * Custom hook for fetching distinct size values from beads
 *
 * @param filters - Object containing filter parameters
 * @returns Query result with size strings array directly accessible, loading state, and error
 */
export const useBeadSizesQuery = (filters: Record<string, string> = {}) => {
  return useQuery({
    queryKey: ['bead-sizes', filters],
    queryFn: () => fetchData<string[]>('catalog/bead_sizes', filters),
  });
};

export default useBeadSizesQuery;

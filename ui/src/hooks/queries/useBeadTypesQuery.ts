// noinspection ES6PreferShortImport

import { useQuery } from '@tanstack/react-query';
import { fetchData } from '../../services/queryUtils';

/**
 * Custom hook for fetching distinct shape values from beads (replaces types)
 *
 * @param filters - Object containing filter parameters
 * @returns Query result with shape strings array directly accessible, loading state, and error
 */
export const useBeadTypesQuery = (filters: Record<string, string> = {}) => {
  return useQuery({
    queryKey: ['bead-types', filters],
    queryFn: () => fetchData<string[]>('catalog/bead_types', filters),
  });
};

export default useBeadTypesQuery;

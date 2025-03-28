// noinspection ES6PreferShortImport

import { useQuery } from '@tanstack/react-query';
import { fetchData } from '../../services/queryUtils';
import { BeadSize } from '../../types/beads.ts';

/**
 * Custom hook for fetching bead sizes with filtering
 *
 * @param filters - Object containing filter parameters
 * @returns Query result with sizes array directly accessible, loading state, and error
 */
export const useBeadSizesQuery = (filters: Record<string, string> = {}) => {
  return useQuery({
    queryKey: ['bead-sizes', filters],
    queryFn: () => fetchData<BeadSize[]>('catalog/bead_sizes', filters),
  });
};

export default useBeadSizesQuery;

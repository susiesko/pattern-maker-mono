// noinspection ES6PreferShortImport

import { useQuery } from '@tanstack/react-query';
import { fetchData } from '../../services/queryUtils';
import { BeadType } from '../../types/beads.ts';

/**
 * Custom hook for fetching bead types with filtering
 *
 * @param filters - Object containing filter parameters
 * @returns Query result with types array directly accessible, loading state, and error
 */
export const useBeadTypesQuery = (filters: Record<string, string> = {}) => {
  return useQuery({
    queryKey: ['bead-types', filters],
    queryFn: () => fetchData<BeadType[]>('catalog/bead_types', filters),
  });
};

export default useBeadTypesQuery;

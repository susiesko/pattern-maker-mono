import { useQuery } from '@tanstack/react-query';
import { fetchData } from '../../services/queryUtils';

/**
 * Custom hook for fetching distinct finish values from beads
 *
 * @param filters - Object containing filter parameters
 * @returns Query result with finish strings array directly accessible, loading state, and error
 */
export const useBeadFinishesQuery = (filters: Record<string, string> = {}) => {
  return useQuery({
    queryKey: ['bead-finishes', filters],
    queryFn: () => fetchData<string[]>('catalog/bead_finishes', filters),
  });
};

export default useBeadFinishesQuery;

import { useQuery } from '@tanstack/react-query';
import { fetchData } from '../../services/queryUtils';
import { BeadFinish } from '../../types/beads.ts';

/**
 * Custom hook for fetching bead finishes with filtering
 *
 * @param filters - Object containing filter parameters
 * @returns Query result with finishes array directly accessible, loading state, and error
 */
export const useBeadFinishesQuery = (filters: Record<string, string> = {}) => {
  return useQuery({
    queryKey: ['bead-finishes', filters],
    queryFn: () => fetchData<BeadFinish[]>('catalog/bead_finishes', filters),
  });
};

export default useBeadFinishesQuery;

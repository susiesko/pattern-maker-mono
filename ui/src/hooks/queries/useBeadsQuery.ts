import { useQuery } from '@tanstack/react-query';
import { fetchData } from '../../services/queryUtils';
import { Bead } from '../../types/beads.ts';

/**
 * Custom hook for fetching beads with pagination and filtering
 *
 * @param filters - Object containing filter parameters
 * @returns Query result with beads array directly accessible, loading state, and error
 */
export const useBeadsQuery = (filters: Record<string, string> = {}) => {
  return useQuery({
    queryKey: ['beads', filters],
    queryFn: () => fetchData<Bead[]>('catalog/beads', filters),
  });
};

export default useBeadsQuery;

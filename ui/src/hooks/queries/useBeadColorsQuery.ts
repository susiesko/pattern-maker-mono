import { useQuery } from '@tanstack/react-query';
import { fetchData } from '../../services/queryUtils';

/**
 * Custom hook for fetching distinct color groups from beads
 *
 * @param filters - Object containing filter parameters
 * @returns Query result with color group strings array directly accessible, loading state, and error
 */
export const useBeadColorsQuery = (filters: Record<string, string> = {}) => {
  return useQuery({
    queryKey: ['bead-colors', filters],
    queryFn: () => fetchData<string[]>('catalog/bead_colors', filters),
  });
};

export default useBeadColorsQuery;

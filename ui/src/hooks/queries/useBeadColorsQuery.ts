import { useQuery } from '@tanstack/react-query';
import { fetchData } from '../../services/queryUtils';
import { BeadColor } from '../../types/beads.ts';

/**
 * Custom hook for fetching bead colors with filtering
 *
 * @param filters - Object containing filter parameters
 * @returns Query result with bead colors array directly accessible, loading state, and error
 */
export const useBeadColorsQuery = (filters: Record<string, string> = {}) => {
  return useQuery({
    queryKey: ['bead-colors', filters],
    queryFn: () => fetchData<BeadColor[]>('catalog/bead_colors', filters),
  });
};

export default useBeadColorsQuery;

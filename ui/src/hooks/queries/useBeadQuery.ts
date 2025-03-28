import { useQuery } from '@tanstack/react-query';
import { fetchData } from '../../services/queryUtils';
import { Bead } from '../../types/beads.ts';

/**
 * Custom hook for fetching a single bead by ID
 *
 * @param id - The ID of the bead to fetch
 * @returns Query result with bead data directly accessible, loading state, and error
 */
export const useBeadQuery = (id: number | null) => {
  return useQuery({
    queryKey: ['beads', id],
    queryFn: () => fetchData<Bead>(`catalog/beads/${id}`),
    enabled: id !== null && id !== undefined,
  });
};

export default useBeadQuery;
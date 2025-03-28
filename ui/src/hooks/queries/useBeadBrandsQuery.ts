// noinspection ES6PreferShortImport

import { useQuery } from '@tanstack/react-query';
import { fetchData } from '../../services/queryUtils';
import { BeadBrand } from '../../types/beads';

/**
 * Custom hook for fetching bead brands with filtering
 *
 * @param filters - Object containing filter parameters
 * @returns Query result with brands array directly accessible, loading state, and error
 */
export const useBeadBrandsQuery = (filters: Record<string, string> = {}) => {
  return useQuery({
    queryKey: ['bead-brands', filters],
    queryFn: () => fetchData<BeadBrand[]>('catalog/bead_brands', filters),
  });
};

export default useBeadBrandsQuery;

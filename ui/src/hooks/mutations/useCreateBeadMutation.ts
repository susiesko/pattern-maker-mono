// noinspection ES6PreferShortImport

import { useMutation, useQueryClient } from '@tanstack/react-query';
import api from '../../services/api';
import { Bead } from '../../types/beads';

interface CreateBeadData {
  name: string;
  brand_product_code?: string;
  image?: string;
  brand_id: number;
  size_id: number;
  type_id: number;
  color_ids: number[];
  finish_ids: number[];
  metadata?: Record<string, unknown>;
}

/**
 * Custom hook for creating a new bead
 *
 * @returns Mutation object for creating a bead
 */
export const useCreateBeadMutation = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (data: CreateBeadData) => {
      const response = await api.post<{ data: Bead }>('/catalog/beads', data);
      return response.data.data;
    },
    onSuccess: () => {
      // Invalidate the beads query to refetch the updated list
      void queryClient.invalidateQueries({ queryKey: ['beads'] });
    },
  });
};

export default useCreateBeadMutation;

// noinspection ES6PreferShortImport

import { useMutation, useQueryClient } from '@tanstack/react-query';
import api from '../../services/api';
import { Bead } from '../../types/beads';

interface UpdateBeadData {
  id: number;
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
 * Custom hook for updating an existing bead
 *
 * @returns Mutation object for updating a bead
 */
export const useUpdateBeadMutation = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (data: UpdateBeadData) => {
      const { id, ...updateData } = data;
      const response = await api.put<{ data: Bead }>(`/catalog/beads/${id}`, updateData);
      return response.data.data;
    },
    onSuccess: () => {
      // Invalidate the beads query to refetch the updated list
      void queryClient.invalidateQueries({ queryKey: ['beads'] });
    },
  });
};

export default useUpdateBeadMutation;

import { useMutation, useQueryClient } from '@tanstack/react-query';
import { postData, putData, deleteData } from '../../services/queryUtils';

interface CreateInventoryData {
  bead_id: number;
  quantity: number;
  quantity_unit: string;
}

interface UpdateInventoryData {
  quantity?: number;
  quantity_unit?: string;
}

export const useCreateInventoryMutation = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: CreateInventoryData) => postData('inventories', { inventory: data }),
    onSuccess: (_, variables) => {
      // Invalidate and refetch inventory data
      queryClient.invalidateQueries({ queryKey: ['inventories'] });
      // Also invalidate the specific bead query to update inventory status
      queryClient.invalidateQueries({ queryKey: ['beads', variables.bead_id] });
    },
  });
};

export const useUpdateInventoryMutation = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, data }: { id: number; data: UpdateInventoryData }) => 
      putData(`inventories/${id}`, { inventory: data }),
    onSuccess: (result, variables) => {
      // Invalidate and refetch inventory data
      queryClient.invalidateQueries({ queryKey: ['inventories'] });
      // Also invalidate bead queries to update inventory status
      queryClient.invalidateQueries({ queryKey: ['beads'] });
    },
  });
};

export const useDeleteInventoryMutation = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (id: number) => deleteData(`inventories/${id}`),
    onSuccess: () => {
      // Invalidate and refetch inventory data
      queryClient.invalidateQueries({ queryKey: ['inventories'] });
      // Also invalidate bead queries to update inventory status
      queryClient.invalidateQueries({ queryKey: ['beads'] });
    },
  });
}; 
import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ThemeProvider } from 'styled-components';
import { vi } from 'vitest';
import { AddToInventoryModal } from './AddToInventoryModal';
import { useCreateInventoryMutation, useUpdateInventoryMutation } from '../../hooks/mutations/useInventoryMutations';
import theme from '../../styles/theme';

// Mock the mutation hooks
vi.mock('../../hooks/mutations/useInventoryMutations');

const mockUseCreateInventoryMutation = useCreateInventoryMutation as any;
const mockUseUpdateInventoryMutation = useUpdateInventoryMutation as any;

const createWrapper = () => {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: { retry: false },
      mutations: { retry: false },
    },
  });

  return ({ children }: { children: React.ReactNode }) => (
    <QueryClientProvider client={queryClient}>
      <ThemeProvider theme={theme}>
        {children}
      </ThemeProvider>
    </QueryClientProvider>
  );
};

const mockBead = {
  id: 123,
  name: 'Test Bead',
  brand: { id: 1, name: 'Test Brand' },
  brand_product_code: 'TB001',
  user_inventory: null,
};

const mockBeadWithInventory = {
  ...mockBead,
  user_inventory: {
    id: 456,
    quantity: 25.5,
    quantity_unit: 'grams',
  },
};

const mockCreateMutation = {
  mutateAsync: vi.fn(),
  isPending: false,
};

const mockUpdateMutation = {
  mutateAsync: vi.fn(),
  isPending: false,
};

describe('AddToInventoryModal', () => {
  const mockOnClose = vi.fn();

  beforeEach(() => {
    vi.clearAllMocks();
    mockUseCreateInventoryMutation.mockReturnValue(mockCreateMutation);
    mockUseUpdateInventoryMutation.mockReturnValue(mockUpdateMutation);
  });

  it('renders modal for adding new inventory', () => {
    render(
      <AddToInventoryModal bead={mockBead} onClose={mockOnClose} />,
      { wrapper: createWrapper() }
    );

    expect(screen.getByRole('heading', { name: 'Add to Inventory' })).toBeInTheDocument();
    expect(screen.getByText('Test Bead')).toBeInTheDocument();
    expect(screen.getByText('Test Brand')).toBeInTheDocument();
    expect(screen.getByLabelText('Quantity *')).toBeInTheDocument();
    expect(screen.getByLabelText('Unit')).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Add to Inventory' })).toBeInTheDocument();
  });

  it('renders modal for updating existing inventory', () => {
    render(
      <AddToInventoryModal bead={mockBeadWithInventory} onClose={mockOnClose} />,
      { wrapper: createWrapper() }
    );

    expect(screen.getByRole('heading', { name: 'Update Inventory' })).toBeInTheDocument();
    expect(screen.getByText('Current: 25.5 grams')).toBeInTheDocument();
    expect(screen.getByLabelText('New Quantity *')).toHaveValue(25.5);
    expect(screen.getByLabelText('Unit')).toHaveValue('grams');
    expect(screen.getByRole('button', { name: 'Update Inventory' })).toBeInTheDocument();
  });

  it('creates new inventory item when submitted', async () => {
    mockCreateMutation.mutateAsync.mockResolvedValue({});

    render(
      <AddToInventoryModal bead={mockBead} onClose={mockOnClose} />,
      { wrapper: createWrapper() }
    );

    const quantityInput = screen.getByLabelText('Quantity *');
    const unitSelect = screen.getByLabelText('Unit');
    const submitButton = screen.getByRole('button', { name: 'Add to Inventory' });

    fireEvent.change(quantityInput, { target: { value: '10.5' } });
    fireEvent.change(unitSelect, { target: { value: 'grams' } });
    fireEvent.click(submitButton);

    await waitFor(() => {
      expect(mockCreateMutation.mutateAsync).toHaveBeenCalledWith({
        bead_id: 123,
        quantity: 10.5,
        quantity_unit: 'grams',
      });
    });

    expect(mockOnClose).toHaveBeenCalled();
  });

  it('updates existing inventory item when submitted', async () => {
    mockUpdateMutation.mutateAsync.mockResolvedValue({});

    render(
      <AddToInventoryModal bead={mockBeadWithInventory} onClose={mockOnClose} />,
      { wrapper: createWrapper() }
    );

    const quantityInput = screen.getByLabelText('New Quantity *');
    const submitButton = screen.getByRole('button', { name: 'Update Inventory' });

    fireEvent.change(quantityInput, { target: { value: '50' } });
    fireEvent.click(submitButton);

    await waitFor(() => {
      expect(mockUpdateMutation.mutateAsync).toHaveBeenCalledWith({
        id: 456,
        data: {
          quantity: 50,
          quantity_unit: 'grams',
        },
      });
    });

    expect(mockOnClose).toHaveBeenCalled();
  });

  it('validates quantity input', async () => {
    render(
      <AddToInventoryModal bead={mockBead} onClose={mockOnClose} />,
      { wrapper: createWrapper() }
    );

    const submitButton = screen.getByRole('button', { name: 'Add to Inventory' });

    // Submit without quantity
    fireEvent.click(submitButton);

    await waitFor(() => {
      expect(screen.getByText('Please enter a valid quantity greater than 0')).toBeInTheDocument();
    });

    expect(mockCreateMutation.mutateAsync).not.toHaveBeenCalled();
    expect(mockOnClose).not.toHaveBeenCalled();
  });

  it('handles API errors gracefully', async () => {
    mockCreateMutation.mutateAsync.mockRejectedValue(new Error('API Error'));

    render(
      <AddToInventoryModal bead={mockBead} onClose={mockOnClose} />,
      { wrapper: createWrapper() }
    );

    const quantityInput = screen.getByLabelText('Quantity *');
    const submitButton = screen.getByRole('button', { name: 'Add to Inventory' });

    fireEvent.change(quantityInput, { target: { value: '10' } });
    fireEvent.click(submitButton);

    await waitFor(() => {
      expect(screen.getByText('Failed to save inventory. Please try again.')).toBeInTheDocument();
    });

    expect(mockOnClose).not.toHaveBeenCalled();
  });

  it('shows loading state during submission', () => {
    mockUseCreateInventoryMutation.mockReturnValue({
      ...mockCreateMutation,
      isPending: true,
    });

    render(
      <AddToInventoryModal bead={mockBead} onClose={mockOnClose} />,
      { wrapper: createWrapper() }
    );

    const submitButton = screen.getByRole('button', { name: 'Saving...' });
    expect(submitButton).toBeDisabled();
  });

  it('closes modal when cancel button is clicked', () => {
    render(
      <AddToInventoryModal bead={mockBead} onClose={mockOnClose} />,
      { wrapper: createWrapper() }
    );

    const cancelButton = screen.getByRole('button', { name: 'Cancel' });
    fireEvent.click(cancelButton);

    expect(mockOnClose).toHaveBeenCalled();
  });

  it('closes modal when backdrop is clicked', () => {
    render(
      <AddToInventoryModal bead={mockBead} onClose={mockOnClose} />,
      { wrapper: createWrapper() }
    );

    const backdrop = screen.getByRole('dialog').parentElement;
    fireEvent.click(backdrop!);

    expect(mockOnClose).toHaveBeenCalled();
  });

  it('does not close modal when modal content is clicked', () => {
    render(
      <AddToInventoryModal bead={mockBead} onClose={mockOnClose} />,
      { wrapper: createWrapper() }
    );

    const modalContent = screen.getByRole('dialog');
    fireEvent.click(modalContent);

    expect(mockOnClose).not.toHaveBeenCalled();
  });

  it('supports all quantity units', () => {
    render(
      <AddToInventoryModal bead={mockBead} onClose={mockOnClose} />,
      { wrapper: createWrapper() }
    );

    const unitSelect = screen.getByLabelText('Unit');
    expect(unitSelect).toHaveTextContent('Units');
    expect(unitSelect).toHaveTextContent('Grams');
    expect(unitSelect).toHaveTextContent('Ounces');
    expect(unitSelect).toHaveTextContent('Pounds');
  });
}); 
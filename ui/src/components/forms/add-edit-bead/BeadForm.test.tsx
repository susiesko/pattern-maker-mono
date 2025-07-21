import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { vi } from 'vitest';
import { MemoryRouter } from 'react-router-dom';
import BeadForm from './BeadForm.tsx';
import useBeadBrandsQuery from '../../../hooks/queries/useBeadBrandsQuery.ts';
import useBeadSizesQuery from '../../../hooks/queries/useBeadSizesQuery.ts';
import useBeadTypesQuery from '../../../hooks/queries/useBeadTypesQuery.ts';
import useBeadColorsQuery from '../../../hooks/queries/useBeadColorsQuery.ts';
import useBeadFinishesQuery from '../../../hooks/queries/useBeadFinishesQuery.ts';
import useCreateBeadMutation from '../../../hooks/mutations/useCreateBeadMutation.ts';
import useUpdateBeadMutation from '../../../hooks/mutations/useUpdateBeadMutation.ts';
import { createTestWrapper } from '../../../utils/testUtils.tsx';

// Mock the hooks
vi.mock('../../../hooks/queries/useBeadBrandsQuery.ts');
vi.mock('../../../hooks/queries/useBeadSizesQuery.ts');
vi.mock('../../../hooks/queries/useBeadTypesQuery.ts');
vi.mock('../../../hooks/queries/useBeadColorsQuery.ts');
vi.mock('../../../hooks/queries/useBeadFinishesQuery.ts');
vi.mock('../../../hooks/mutations/useCreateBeadMutation.ts');
vi.mock('../../../hooks/mutations/useUpdateBeadMutation.ts');
vi.mock('react-router-dom', async () => {
  const actual = await vi.importActual('react-router-dom');
  return {
    ...actual,
    useNavigate: () => vi.fn(),
  };
});

describe('BeadForm', () => {
  const mockBrands = [
    { id: 1, name: 'Brand 1', website: 'https://brand1.com' },
    { id: 2, name: 'Brand 2', website: 'https://brand2.com' },
  ];

  // New schema - these are now string arrays
  const mockShapes = ['Seed', 'Delica'];
  const mockSizes = ['11/0', '8/0'];
  const mockColors = ['Red', 'Blue'];
  const mockFinishes = ['Matte', 'Glossy'];

  const mockBead = {
    id: 1,
    name: 'Test Bead',
    brand_product_code: 'TB-123',
    image: 'test.jpg',
    metadata: {},
    created_at: '2023-01-01T00:00:00Z',
    updated_at: '2023-01-01T00:00:00Z',
    brand: { id: 1, name: 'Brand 1', website: 'https://brand1.com' },
    // New simplified schema - direct string attributes
    shape: 'Seed',
    size: '11/0',
    color_group: 'Red',
    glass_group: 'Opaque',
    finish: 'Matte',
    dyed: 'No',
    galvanized: 'No',
    plating: 'None',
  };

  const mockCreateMutation = {
    mutateAsync: vi.fn().mockResolvedValue({}),
    isPending: false,
  };

  const mockUpdateMutation = {
    mutateAsync: vi.fn().mockResolvedValue({}),
    isPending: false,
  };

  beforeEach(() => {
    vi.clearAllMocks();

    // Setup mock returns
    (useBeadBrandsQuery as any).mockReturnValue({
      data: mockBrands,
      isLoading: false,
    });

    (useBeadSizesQuery as any).mockReturnValue({
      data: mockSizes,
      isLoading: false,
    });

    (useBeadTypesQuery as any).mockReturnValue({
      data: mockShapes,
      isLoading: false,
    });

    (useBeadColorsQuery as any).mockReturnValue({
      data: mockColors,
      isLoading: false,
    });

    (useBeadFinishesQuery as any).mockReturnValue({
      data: mockFinishes,
      isLoading: false,
    });

    (useCreateBeadMutation as any).mockReturnValue(mockCreateMutation);
    (useUpdateBeadMutation as any).mockReturnValue(mockUpdateMutation);
  });

  test('renders the form with correct title for new bead', () => {
    render(
      <MemoryRouter>
        <BeadForm />
      </MemoryRouter>,
      { wrapper: createTestWrapper() }
    );

    expect(screen.getByText('Add New Bead')).toBeInTheDocument();
  });

  test('renders the form with correct title for edit mode', () => {
    render(
      <MemoryRouter>
        <BeadForm bead={mockBead} isEdit={true} />
      </MemoryRouter>,
      { wrapper: createTestWrapper() }
    );

    expect(screen.getByText('Edit Bead')).toBeInTheDocument();
  });

  test('populates form fields with bead data in edit mode', () => {
    render(
      <MemoryRouter>
        <BeadForm bead={mockBead} isEdit={true} />
      </MemoryRouter>,
      { wrapper: createTestWrapper() }
    );

    expect(screen.getByDisplayValue('Test Bead')).toBeInTheDocument();
    expect(screen.getByDisplayValue('TB-123')).toBeInTheDocument();
    expect(screen.getByDisplayValue('test.jpg')).toBeInTheDocument();
  });

  test('shows loading state when data is loading', () => {
    (useBeadBrandsQuery as any).mockReturnValue({
      data: null,
      isLoading: true,
    });

    render(
      <MemoryRouter>
        <BeadForm />
      </MemoryRouter>,
      { wrapper: createTestWrapper() }
    );

    expect(screen.getByText('Loading form data...')).toBeInTheDocument();
  });

  test('validates required fields on submit', async () => {
    render(
      <MemoryRouter>
        <BeadForm />
      </MemoryRouter>,
      { wrapper: createTestWrapper() }
    );

    // Submit the form without filling required fields
    fireEvent.click(screen.getByText('Create Bead'));

    // Check for validation errors
    await waitFor(() => {
      expect(screen.getByText('Name is required')).toBeInTheDocument();
      expect(screen.getByText('Brand is required')).toBeInTheDocument();
      expect(screen.getByText('Size is required')).toBeInTheDocument();
      expect(screen.getByText('Color group is required')).toBeInTheDocument();
      expect(screen.getByText('Finish is required')).toBeInTheDocument();
    });

    // Ensure the mutation was not called
    expect(mockCreateMutation.mutateAsync).not.toHaveBeenCalled();
  });

  test('calls create mutation with correct data on submit', async () => {
    render(
      <MemoryRouter>
        <BeadForm />
      </MemoryRouter>,
      { wrapper: createTestWrapper() }
    );

    // Fill out the form
    fireEvent.change(screen.getByLabelText(/Name/), { target: { value: 'New Bead' } });
    fireEvent.change(screen.getByLabelText(/Product Code/), { target: { value: 'NB-456' } });
    fireEvent.change(screen.getByLabelText(/Brand/), { target: { value: '1' } });
    fireEvent.change(screen.getByLabelText(/Size/), { target: { value: '11/0' } });
    fireEvent.change(screen.getByLabelText(/Color Group/), { target: { value: 'Red' } });
    fireEvent.change(screen.getByLabelText(/Finish/), { target: { value: 'Matte' } });

    // Submit the form
    fireEvent.click(screen.getByText('Create Bead'));

    // Check that the mutation was called with the correct data
    await waitFor(() => {
      expect(mockCreateMutation.mutateAsync).toHaveBeenCalledWith({
        name: 'New Bead',
        brand_product_code: 'NB-456',
        image: undefined,
        brand_id: 1,
        size: '11/0',
        color_group: 'Red',
        finish: 'Matte',
        shape: undefined,
        glass_group: undefined,
        dyed: undefined,
        galvanized: undefined,
        plating: undefined,
      });
    });
  });

  test('calls update mutation with correct data on submit in edit mode', async () => {
    render(
      <MemoryRouter>
        <BeadForm bead={mockBead} isEdit={true} />
      </MemoryRouter>,
      { wrapper: createTestWrapper() }
    );

    // Change a field
    fireEvent.change(screen.getByLabelText(/Name/), { target: { value: 'Updated Bead' } });

    // Submit the form
    fireEvent.click(screen.getByText('Update Bead'));

    // Check that the mutation was called with the correct data
    await waitFor(() => {
      expect(mockUpdateMutation.mutateAsync).toHaveBeenCalledWith({
        id: 1,
        name: 'Updated Bead',
        brand_product_code: 'TB-123',
        image: 'test.jpg',
        brand_id: 1,
        size: '11/0',
        color_group: 'Red',
        finish: 'Matte',
        shape: 'Seed',
        glass_group: 'Opaque',
        dyed: 'No',
        galvanized: 'No',
        plating: 'None',
      });
    });
  });
});

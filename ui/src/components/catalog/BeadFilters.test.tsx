import { render, screen, fireEvent } from '@testing-library/react';
import { vi } from 'vitest';
import BeadFilters from './BeadFilters';
import { createTestWrapper } from '../../test/testUtils';

// Mock the query hooks
vi.mock('../../hooks/queries', () => ({
  useBeadBrandsQuery: vi.fn(),
  useBeadTypesQuery: vi.fn(),
  useBeadSizesQuery: vi.fn(),
  useBeadColorsQuery: vi.fn(),
  useBeadFinishesQuery: vi.fn(),
}));

import {
  useBeadBrandsQuery,
  useBeadTypesQuery,
  useBeadSizesQuery,
  useBeadColorsQuery,
  useBeadFinishesQuery,
} from '../../hooks/queries';

const mockUseBeadBrandsQuery = vi.mocked(useBeadBrandsQuery);
const mockUseBeadTypesQuery = vi.mocked(useBeadTypesQuery);
const mockUseBeadSizesQuery = vi.mocked(useBeadSizesQuery);
const mockUseBeadColorsQuery = vi.mocked(useBeadColorsQuery);
const mockUseBeadFinishesQuery = vi.mocked(useBeadFinishesQuery);

describe('BeadFilters', () => {
  const mockOnChange = vi.fn();

  const defaultFilters = {
    brandId: '',
    shape: '',
    size: '',
    color_group: '',
    finish: '',
  };

  const mockBrands = [
    { id: 1, name: 'Brand A', website: 'https://brand-a.com' },
    { id: 2, name: 'Brand B', website: 'https://brand-b.com' },
  ];

  // New schema - these are now string arrays
  const mockShapes = ['Seed', 'Delica'];
  const mockSizes = ['11/0', '8/0'];
  const mockColors = ['Red', 'Blue'];
  const mockFinishes = ['Matte', 'Transparent'];

  beforeEach(() => {
    vi.clearAllMocks();

    // Set up default mock responses with proper query result structure
    mockUseBeadBrandsQuery.mockReturnValue({ 
      data: mockBrands,
      isLoading: false,
      error: null,
      refetch: vi.fn(),
    } as any);
    mockUseBeadTypesQuery.mockReturnValue({ 
      data: mockShapes,
      isLoading: false,
      error: null,
      refetch: vi.fn(),
    } as any);
    mockUseBeadSizesQuery.mockReturnValue({ 
      data: mockSizes,
      isLoading: false,
      error: null,
      refetch: vi.fn(),
    } as any);
    mockUseBeadColorsQuery.mockReturnValue({ 
      data: mockColors,
      isLoading: false,
      error: null,
      refetch: vi.fn(),
    } as any);
    mockUseBeadFinishesQuery.mockReturnValue({ 
      data: mockFinishes,
      isLoading: false,
      error: null,
      refetch: vi.fn(),
    } as any);
  });

  const renderBeadFilters = (filters = defaultFilters) => {
    return render(
      <BeadFilters
        filters={filters}
        onChange={mockOnChange}
      />,
      { wrapper: createTestWrapper() }
    );
  };

  describe('Rendering', () => {
    it('renders all filter dropdowns', () => {
      renderBeadFilters();

      expect(screen.getByLabelText('Brand')).toBeInTheDocument();
      expect(screen.getByLabelText('Shape')).toBeInTheDocument();
      expect(screen.getByLabelText('Size')).toBeInTheDocument();
      expect(screen.getByLabelText('Color')).toBeInTheDocument();
      expect(screen.getByLabelText('Finish')).toBeInTheDocument();
    });

    it('renders brand options correctly', () => {
      renderBeadFilters();

      const brandSelect = screen.getByLabelText('Brand');
      expect(brandSelect).toContainHTML('<option value="">All Brands</option>');
      expect(brandSelect).toContainHTML('<option value="1">Brand A</option>');
      expect(brandSelect).toContainHTML('<option value="2">Brand B</option>');
    });

    it('renders shape options correctly', () => {
      renderBeadFilters();

      const shapeSelect = screen.getByLabelText('Shape');
      expect(shapeSelect).toContainHTML('<option value="">All Shapes</option>');
      expect(shapeSelect).toContainHTML('<option value="Seed">Seed</option>');
      expect(shapeSelect).toContainHTML('<option value="Delica">Delica</option>');
    });

    it('renders size options correctly', () => {
      renderBeadFilters();

      const sizeSelect = screen.getByLabelText('Size');
      expect(sizeSelect).toContainHTML('<option value="">All Sizes</option>');
      expect(sizeSelect).toContainHTML('<option value="11/0">11/0</option>');
      expect(sizeSelect).toContainHTML('<option value="8/0">8/0</option>');
    });

    it('renders color options correctly', () => {
      renderBeadFilters();

      const colorSelect = screen.getByLabelText('Color');
      expect(colorSelect).toContainHTML('<option value="">All Colors</option>');
      expect(colorSelect).toContainHTML('<option value="Red">Red</option>');
      expect(colorSelect).toContainHTML('<option value="Blue">Blue</option>');
    });

    it('renders finish options correctly', () => {
      renderBeadFilters();

      const finishSelect = screen.getByLabelText('Finish');
      expect(finishSelect).toContainHTML('<option value="">All Finishes</option>');
      expect(finishSelect).toContainHTML('<option value="Matte">Matte</option>');
      expect(finishSelect).toContainHTML('<option value="Transparent">Transparent</option>');
    });
  });

  describe('Filter Interactions', () => {
    it('calls onChange when brand filter changes', () => {
      renderBeadFilters();

      const brandSelect = screen.getByLabelText('Brand');
      fireEvent.change(brandSelect, { target: { value: '1' } });

      expect(mockOnChange).toHaveBeenCalledWith({ brandId: '1' });
    });

    it('calls onChange when shape filter changes', () => {
      renderBeadFilters();

      const shapeSelect = screen.getByLabelText('Shape');
      fireEvent.change(shapeSelect, { target: { value: 'Delica' } });

      expect(mockOnChange).toHaveBeenCalledWith({ shape: 'Delica' });
    });

    it('calls onChange when size filter changes', () => {
      renderBeadFilters();

      const sizeSelect = screen.getByLabelText('Size');
      fireEvent.change(sizeSelect, { target: { value: '11/0' } });

      expect(mockOnChange).toHaveBeenCalledWith({ size: '11/0' });
    });

    it('calls onChange when color filter changes', () => {
      renderBeadFilters();

      const colorSelect = screen.getByLabelText('Color');
      fireEvent.change(colorSelect, { target: { value: 'Blue' } });

      expect(mockOnChange).toHaveBeenCalledWith({ color_group: 'Blue' });
    });

    it('calls onChange when finish filter changes', () => {
      renderBeadFilters();

      const finishSelect = screen.getByLabelText('Finish');
      fireEvent.change(finishSelect, { target: { value: 'Matte' } });

      expect(mockOnChange).toHaveBeenCalledWith({ finish: 'Matte' });
    });
  });

  describe('Filter Values', () => {
    it('displays selected brand value', () => {
      const filtersWithBrand = { ...defaultFilters, brandId: '1' };
      renderBeadFilters(filtersWithBrand);

      const brandSelect = screen.getByLabelText('Brand');
      expect(brandSelect).toHaveValue('1');
    });

    it('displays selected shape value', () => {
      const filtersWithShape = { ...defaultFilters, shape: 'Delica' };
      renderBeadFilters(filtersWithShape);

      const shapeSelect = screen.getByLabelText('Shape');
      expect(shapeSelect).toHaveValue('Delica');
    });

    it('displays selected size value', () => {
      const filtersWithSize = { ...defaultFilters, size: '11/0' };
      renderBeadFilters(filtersWithSize);

      const sizeSelect = screen.getByLabelText('Size');
      expect(sizeSelect).toHaveValue('11/0');
    });

    it('displays selected color value', () => {
      const filtersWithColor = { ...defaultFilters, color_group: 'Blue' };
      renderBeadFilters(filtersWithColor);

      const colorSelect = screen.getByLabelText('Color');
      expect(colorSelect).toHaveValue('Blue');
    });

    it('displays selected finish value', () => {
      const filtersWithFinish = { ...defaultFilters, finish: 'Matte' };
      renderBeadFilters(filtersWithFinish);

      const finishSelect = screen.getByLabelText('Finish');
      expect(finishSelect).toHaveValue('Matte');
    });
  });

  describe('Clear Filters', () => {
    it('shows clear filters button when filters are active', () => {
      const activeFilters = { ...defaultFilters, brandId: '1' };
      renderBeadFilters(activeFilters);

      const clearButton = screen.getByText('Clear All Filters');
      expect(clearButton).toBeInTheDocument();
    });

    it('does not show clear filters button when no filters are active', () => {
      renderBeadFilters();

      const clearButton = screen.queryByText('Clear All Filters');
      expect(clearButton).not.toBeInTheDocument();
    });

    it('calls onChange with empty filters when clear button is clicked', () => {
      const activeFilters = { ...defaultFilters, brandId: '1', color_group: 'Blue' };
      renderBeadFilters(activeFilters);

      const clearButton = screen.getByText('Clear All Filters');
      fireEvent.click(clearButton);

      expect(mockOnChange).toHaveBeenCalledWith({
        brandId: '',
        shape: '',
        size: '',
        color_group: '',
        finish: '',
      });
    });

    it('shows clear button when any filter is active', () => {
      const testCases = [
        { brandId: '1', shape: '', size: '', color_group: '', finish: '' },
        { brandId: '', shape: 'Seed', size: '', color_group: '', finish: '' },
        { brandId: '', shape: '', size: '11/0', color_group: '', finish: '' },
        { brandId: '', shape: '', size: '', color_group: 'Red', finish: '' },
        { brandId: '', shape: '', size: '', color_group: '', finish: 'Matte' },
      ];

      testCases.forEach((filters) => {
        const { unmount } = renderBeadFilters(filters);

        const clearButton = screen.getByText('Clear All Filters');
        expect(clearButton).toBeInTheDocument();

        unmount();
      });
    });
  });

  describe('Loading States', () => {
    it('handles undefined data gracefully', () => {
      mockUseBeadBrandsQuery.mockReturnValue({ 
        data: undefined,
        isLoading: true,
        error: null,
        refetch: vi.fn(),
      } as any);
      mockUseBeadTypesQuery.mockReturnValue({ 
        data: undefined,
        isLoading: true,
        error: null,
        refetch: vi.fn(),
      } as any);
      mockUseBeadSizesQuery.mockReturnValue({ 
        data: undefined,
        isLoading: true,
        error: null,
        refetch: vi.fn(),
      } as any);
      mockUseBeadColorsQuery.mockReturnValue({ 
        data: undefined,
        isLoading: true,
        error: null,
        refetch: vi.fn(),
      } as any);
      mockUseBeadFinishesQuery.mockReturnValue({ 
        data: undefined,
        isLoading: true,
        error: null,
        refetch: vi.fn(),
      } as any);

      renderBeadFilters();

      // Should still render the dropdowns with just the "All" options
      expect(screen.getByLabelText('Brand')).toBeInTheDocument();
      expect(screen.getByLabelText('Shape')).toBeInTheDocument();
      expect(screen.getByLabelText('Size')).toBeInTheDocument();
      expect(screen.getByLabelText('Color')).toBeInTheDocument();
      expect(screen.getByLabelText('Finish')).toBeInTheDocument();
    });

    it('handles empty data arrays gracefully', () => {
      mockUseBeadBrandsQuery.mockReturnValue({ 
        data: [],
        isLoading: false,
        error: null,
        refetch: vi.fn(),
      } as any);
      mockUseBeadTypesQuery.mockReturnValue({ 
        data: [],
        isLoading: false,
        error: null,
        refetch: vi.fn(),
      } as any);
      mockUseBeadSizesQuery.mockReturnValue({ 
        data: [],
        isLoading: false,
        error: null,
        refetch: vi.fn(),
      } as any);
      mockUseBeadColorsQuery.mockReturnValue({ 
        data: [],
        isLoading: false,
        error: null,
        refetch: vi.fn(),
      } as any);
      mockUseBeadFinishesQuery.mockReturnValue({ 
        data: [],
        isLoading: false,
        error: null,
        refetch: vi.fn(),
      } as any);

      renderBeadFilters();

      // Should render dropdowns with only "All" options
      const brandSelect = screen.getByLabelText('Brand');
      expect(brandSelect).toContainHTML('<option value="">All Brands</option>');
      expect(brandSelect.children.length).toBe(1);
    });
  });

  describe('Accessibility', () => {
    it('has proper labels for all select elements', () => {
      renderBeadFilters();

      const brandSelect = screen.getByLabelText('Brand');
      const shapeSelect = screen.getByLabelText('Shape');
      const sizeSelect = screen.getByLabelText('Size');
      const colorSelect = screen.getByLabelText('Color');
      const finishSelect = screen.getByLabelText('Finish');

      expect(brandSelect).toBeInTheDocument();
      expect(shapeSelect).toBeInTheDocument();
      expect(sizeSelect).toBeInTheDocument();
      expect(colorSelect).toBeInTheDocument();
      expect(finishSelect).toBeInTheDocument();
    });

    it('clear button has proper type attribute', () => {
      const activeFilters = { ...defaultFilters, brandId: '1' };
      renderBeadFilters(activeFilters);

      const clearButton = screen.getByText('Clear All Filters');
      expect(clearButton).toHaveAttribute('type', 'button');
    });
  });

  describe('Data Integration', () => {
    it('calls all required query hooks', () => {
      renderBeadFilters();

      expect(mockUseBeadBrandsQuery).toHaveBeenCalled();
      expect(mockUseBeadTypesQuery).toHaveBeenCalled();
      expect(mockUseBeadSizesQuery).toHaveBeenCalled();
      expect(mockUseBeadColorsQuery).toHaveBeenCalled();
      expect(mockUseBeadFinishesQuery).toHaveBeenCalled();
    });

    it('handles mixed data availability', () => {
      // Some data available, some not
      mockUseBeadBrandsQuery.mockReturnValue({ 
        data: mockBrands,
        isLoading: false,
        error: null,
        refetch: vi.fn(),
      } as any);
      mockUseBeadTypesQuery.mockReturnValue({ 
        data: undefined,
        isLoading: true,
        error: null,
        refetch: vi.fn(),
      } as any);
      mockUseBeadSizesQuery.mockReturnValue({ 
        data: [],
        isLoading: false,
        error: null,
        refetch: vi.fn(),
      } as any);
      mockUseBeadColorsQuery.mockReturnValue({ 
        data: mockColors,
        isLoading: false,
        error: null,
        refetch: vi.fn(),
      } as any);
      mockUseBeadFinishesQuery.mockReturnValue({ 
        data: undefined,
        isLoading: true,
        error: null,
        refetch: vi.fn(),
      } as any);

      renderBeadFilters();

      // Brand dropdown should have options
      const brandSelect = screen.getByLabelText('Brand');
      expect(brandSelect.children.length).toBe(3); // "All Brands" + 2 brands

      // Color dropdown should have options
      const colorSelect = screen.getByLabelText('Color');
      expect(colorSelect.children.length).toBe(3); // "All Colors" + 2 colors

      // Shape dropdown should only have "All" option
      const shapeSelect = screen.getByLabelText('Shape');
      expect(shapeSelect.children.length).toBe(1); // Only "All Shapes"
    });
  });
}); 
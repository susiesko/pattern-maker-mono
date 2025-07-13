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
    typeId: '',
    sizeId: '',
    colorId: '',
    finishId: '',
  };

  const mockBrands = [
    { id: 1, name: 'Brand A', website: 'https://brand-a.com' },
    { id: 2, name: 'Brand B', website: 'https://brand-b.com' },
  ];

  const mockTypes = [
    { id: 1, name: 'Seed' },
    { id: 2, name: 'Delica' },
  ];

  const mockSizes = [
    { id: 1, size: '11/0' },
    { id: 2, size: '8/0' },
  ];

  const mockColors = [
    { id: 1, name: 'Red' },
    { id: 2, name: 'Blue' },
  ];

  const mockFinishes = [
    { id: 1, name: 'Matte' },
    { id: 2, name: 'Transparent' },
  ];

  beforeEach(() => {
    vi.clearAllMocks();

    // Set up default mock responses
    mockUseBeadBrandsQuery.mockReturnValue({ data: mockBrands });
    mockUseBeadTypesQuery.mockReturnValue({ data: mockTypes });
    mockUseBeadSizesQuery.mockReturnValue({ data: mockSizes });
    mockUseBeadColorsQuery.mockReturnValue({ data: mockColors });
    mockUseBeadFinishesQuery.mockReturnValue({ data: mockFinishes });
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
      expect(screen.getByLabelText('Type')).toBeInTheDocument();
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

    it('renders type options correctly', () => {
      renderBeadFilters();

      const typeSelect = screen.getByLabelText('Type');
      expect(typeSelect).toContainHTML('<option value="">All Types</option>');
      expect(typeSelect).toContainHTML('<option value="1">Seed</option>');
      expect(typeSelect).toContainHTML('<option value="2">Delica</option>');
    });

    it('renders size options correctly', () => {
      renderBeadFilters();

      const sizeSelect = screen.getByLabelText('Size');
      expect(sizeSelect).toContainHTML('<option value="">All Sizes</option>');
      expect(sizeSelect).toContainHTML('<option value="1">11/0</option>');
      expect(sizeSelect).toContainHTML('<option value="2">8/0</option>');
    });

    it('renders color options correctly', () => {
      renderBeadFilters();

      const colorSelect = screen.getByLabelText('Color');
      expect(colorSelect).toContainHTML('<option value="">All Colors</option>');
      expect(colorSelect).toContainHTML('<option value="1">Red</option>');
      expect(colorSelect).toContainHTML('<option value="2">Blue</option>');
    });

    it('renders finish options correctly', () => {
      renderBeadFilters();

      const finishSelect = screen.getByLabelText('Finish');
      expect(finishSelect).toContainHTML('<option value="">All Finishes</option>');
      expect(finishSelect).toContainHTML('<option value="1">Matte</option>');
      expect(finishSelect).toContainHTML('<option value="2">Transparent</option>');
    });
  });

  describe('Filter Interactions', () => {
    it('calls onChange when brand filter changes', () => {
      renderBeadFilters();

      const brandSelect = screen.getByLabelText('Brand');
      fireEvent.change(brandSelect, { target: { value: '1' } });

      expect(mockOnChange).toHaveBeenCalledWith({ brandId: '1' });
    });

    it('calls onChange when type filter changes', () => {
      renderBeadFilters();

      const typeSelect = screen.getByLabelText('Type');
      fireEvent.change(typeSelect, { target: { value: '2' } });

      expect(mockOnChange).toHaveBeenCalledWith({ typeId: '2' });
    });

    it('calls onChange when size filter changes', () => {
      renderBeadFilters();

      const sizeSelect = screen.getByLabelText('Size');
      fireEvent.change(sizeSelect, { target: { value: '1' } });

      expect(mockOnChange).toHaveBeenCalledWith({ sizeId: '1' });
    });

    it('calls onChange when color filter changes', () => {
      renderBeadFilters();

      const colorSelect = screen.getByLabelText('Color');
      fireEvent.change(colorSelect, { target: { value: '2' } });

      expect(mockOnChange).toHaveBeenCalledWith({ colorId: '2' });
    });

    it('calls onChange when finish filter changes', () => {
      renderBeadFilters();

      const finishSelect = screen.getByLabelText('Finish');
      fireEvent.change(finishSelect, { target: { value: '1' } });

      expect(mockOnChange).toHaveBeenCalledWith({ finishId: '1' });
    });
  });

  describe('Filter Values', () => {
    it('displays selected brand value', () => {
      const filtersWithBrand = { ...defaultFilters, brandId: '1' };
      renderBeadFilters(filtersWithBrand);

      const brandSelect = screen.getByLabelText('Brand');
      expect(brandSelect).toHaveValue('1');
    });

    it('displays selected type value', () => {
      const filtersWithType = { ...defaultFilters, typeId: '2' };
      renderBeadFilters(filtersWithType);

      const typeSelect = screen.getByLabelText('Type');
      expect(typeSelect).toHaveValue('2');
    });

    it('displays selected size value', () => {
      const filtersWithSize = { ...defaultFilters, sizeId: '1' };
      renderBeadFilters(filtersWithSize);

      const sizeSelect = screen.getByLabelText('Size');
      expect(sizeSelect).toHaveValue('1');
    });

    it('displays selected color value', () => {
      const filtersWithColor = { ...defaultFilters, colorId: '2' };
      renderBeadFilters(filtersWithColor);

      const colorSelect = screen.getByLabelText('Color');
      expect(colorSelect).toHaveValue('2');
    });

    it('displays selected finish value', () => {
      const filtersWithFinish = { ...defaultFilters, finishId: '1' };
      renderBeadFilters(filtersWithFinish);

      const finishSelect = screen.getByLabelText('Finish');
      expect(finishSelect).toHaveValue('1');
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
      const activeFilters = { ...defaultFilters, brandId: '1', colorId: '2' };
      renderBeadFilters(activeFilters);

      const clearButton = screen.getByText('Clear All Filters');
      fireEvent.click(clearButton);

      expect(mockOnChange).toHaveBeenCalledWith({
        brandId: '',
        typeId: '',
        sizeId: '',
        colorId: '',
        finishId: '',
      });
    });

    it('shows clear button when any filter is active', () => {
      const testCases = [
        { brandId: '1', typeId: '', sizeId: '', colorId: '', finishId: '' },
        { brandId: '', typeId: '1', sizeId: '', colorId: '', finishId: '' },
        { brandId: '', typeId: '', sizeId: '1', colorId: '', finishId: '' },
        { brandId: '', typeId: '', sizeId: '', colorId: '1', finishId: '' },
        { brandId: '', typeId: '', sizeId: '', colorId: '', finishId: '1' },
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
      mockUseBeadBrandsQuery.mockReturnValue({ data: undefined });
      mockUseBeadTypesQuery.mockReturnValue({ data: undefined });
      mockUseBeadSizesQuery.mockReturnValue({ data: undefined });
      mockUseBeadColorsQuery.mockReturnValue({ data: undefined });
      mockUseBeadFinishesQuery.mockReturnValue({ data: undefined });

      renderBeadFilters();

      // Should still render the dropdowns with just the "All" options
      expect(screen.getByLabelText('Brand')).toBeInTheDocument();
      expect(screen.getByLabelText('Type')).toBeInTheDocument();
      expect(screen.getByLabelText('Size')).toBeInTheDocument();
      expect(screen.getByLabelText('Color')).toBeInTheDocument();
      expect(screen.getByLabelText('Finish')).toBeInTheDocument();
    });

    it('handles empty data arrays gracefully', () => {
      mockUseBeadBrandsQuery.mockReturnValue({ data: [] });
      mockUseBeadTypesQuery.mockReturnValue({ data: [] });
      mockUseBeadSizesQuery.mockReturnValue({ data: [] });
      mockUseBeadColorsQuery.mockReturnValue({ data: [] });
      mockUseBeadFinishesQuery.mockReturnValue({ data: [] });

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
      const typeSelect = screen.getByLabelText('Type');
      const sizeSelect = screen.getByLabelText('Size');
      const colorSelect = screen.getByLabelText('Color');
      const finishSelect = screen.getByLabelText('Finish');

      expect(brandSelect).toBeInTheDocument();
      expect(typeSelect).toBeInTheDocument();
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
      mockUseBeadBrandsQuery.mockReturnValue({ data: mockBrands });
      mockUseBeadTypesQuery.mockReturnValue({ data: undefined });
      mockUseBeadSizesQuery.mockReturnValue({ data: [] });
      mockUseBeadColorsQuery.mockReturnValue({ data: mockColors });
      mockUseBeadFinishesQuery.mockReturnValue({ data: undefined });

      renderBeadFilters();

      // Brand dropdown should have options
      const brandSelect = screen.getByLabelText('Brand');
      expect(brandSelect.children.length).toBe(3); // "All Brands" + 2 brands

      // Color dropdown should have options
      const colorSelect = screen.getByLabelText('Color');
      expect(colorSelect.children.length).toBe(3); // "All Colors" + 2 colors

      // Type dropdown should only have "All" option
      const typeSelect = screen.getByLabelText('Type');
      expect(typeSelect.children.length).toBe(1); // Only "All Types"
    });
  });
}); 
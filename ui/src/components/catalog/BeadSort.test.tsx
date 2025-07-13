import { render, screen, fireEvent, cleanup } from '@testing-library/react';
import { vi } from 'vitest';
import BeadSort from './BeadSort';
import { createTestWrapper } from '../../test/testUtils';

describe('BeadSort', () => {
  const mockOnChange = vi.fn();

  const defaultSort = {
    field: 'name' as const,
    direction: 'asc' as const,
  };

  beforeEach(() => {
    vi.clearAllMocks();
    cleanup();
  });

  afterEach(() => {
    cleanup();
  });

  const renderBeadSort = (sort: { field: 'name' | 'brand' | 'created_at' | 'updated_at'; direction: 'asc' | 'desc' } = defaultSort) => {
    return render(
      <BeadSort
        sort={sort}
        onChange={mockOnChange}
      />,
      { wrapper: createTestWrapper() }
    );
  };

  describe('Rendering', () => {
    it('renders sort label and controls', () => {
      renderBeadSort();

      expect(screen.getByText('Sort by:')).toBeInTheDocument();
      expect(screen.getByRole('combobox')).toBeInTheDocument();
    });

    it('renders all sort field options', () => {
      renderBeadSort();

      const select = screen.getByRole('combobox');
      expect(select).toContainHTML('<option value="name">Name</option>');
      expect(select).toContainHTML('<option value="brand">Brand</option>');
      expect(select).toContainHTML('<option value="created_at">Date Added</option>');
      expect(select).toContainHTML('<option value="updated_at">Last Updated</option>');
    });

    it('renders direction toggle buttons', () => {
      renderBeadSort();

      const ascButton = screen.getByTitle('Sort ascending');
      const descButton = screen.getByTitle('Sort descending');

      expect(ascButton).toBeInTheDocument();
      expect(descButton).toBeInTheDocument();
      expect(ascButton).toHaveAttribute('type', 'button');
      expect(descButton).toHaveAttribute('type', 'button');
    });

    it('displays current sort field selection', () => {
      renderBeadSort({ field: 'brand', direction: 'asc' });

      const select = screen.getByRole('combobox');
      expect(select).toHaveValue('brand');
    });
  });

  describe('Sort Field Selection', () => {
    it('calls onChange when sort field changes to name', () => {
      renderBeadSort({ field: 'brand', direction: 'desc' });

      const select = screen.getByRole('combobox');
      fireEvent.change(select, { target: { value: 'name' } });

      expect(mockOnChange).toHaveBeenCalledWith({
        field: 'name',
        direction: 'desc', // Should preserve current direction
      });
    });

    it('calls onChange when sort field changes to brand', () => {
      renderBeadSort({ field: 'name', direction: 'asc' });

      const select = screen.getByRole('combobox');
      fireEvent.change(select, { target: { value: 'brand' } });

      expect(mockOnChange).toHaveBeenCalledWith({
        field: 'brand',
        direction: 'asc',
      });
    });

    it('calls onChange when sort field changes to created_at', () => {
      renderBeadSort();

      const select = screen.getByRole('combobox');
      fireEvent.change(select, { target: { value: 'created_at' } });

      expect(mockOnChange).toHaveBeenCalledWith({
        field: 'created_at',
        direction: 'asc',
      });
    });

    it('calls onChange when sort field changes to updated_at', () => {
      renderBeadSort();

      const select = screen.getByRole('combobox');
      fireEvent.change(select, { target: { value: 'updated_at' } });

      expect(mockOnChange).toHaveBeenCalledWith({
        field: 'updated_at',
        direction: 'asc',
      });
    });
  });

  describe('Sort Direction Toggle', () => {
    it('calls onChange when ascending button is clicked', () => {
      renderBeadSort({ field: 'name', direction: 'desc' });

      const ascButton = screen.getByTitle('Sort ascending');
      fireEvent.click(ascButton);

      expect(mockOnChange).toHaveBeenCalledWith({
        field: 'name',
        direction: 'asc',
      });
    });

    it('calls onChange when descending button is clicked', () => {
      renderBeadSort({ field: 'name', direction: 'asc' });

      const descButton = screen.getByTitle('Sort descending');
      fireEvent.click(descButton);

      expect(mockOnChange).toHaveBeenCalledWith({
        field: 'name',
        direction: 'desc',
      });
    });

    it('preserves current field when direction changes', () => {
      renderBeadSort({ field: 'brand', direction: 'asc' });

      const descButton = screen.getByTitle('Sort descending');
      fireEvent.click(descButton);

      expect(mockOnChange).toHaveBeenCalledWith({
        field: 'brand', // Should preserve current field
        direction: 'desc',
      });
    });
  });

  describe('Visual State Indicators', () => {
    it('highlights ascending button when direction is asc', () => {
      renderBeadSort({ field: 'name', direction: 'asc' });

      const ascButton = screen.getByTitle('Sort ascending');
      const descButton = screen.getByTitle('Sort descending');

      // Ascending button should be active (have primary color background)
      expect(ascButton).toHaveStyle('background-color: rgb(58, 123, 200)'); // theme.colors.primaryDark

      // Descending button should be inactive (secondary background)
      expect(descButton).toHaveStyle('background-color: rgb(245, 245, 245)');
    });

    it('highlights descending button when direction is desc', () => {
      renderBeadSort({ field: 'name', direction: 'desc' });

      const ascButton = screen.getByTitle('Sort ascending');
      const descButton = screen.getByTitle('Sort descending');

      // Descending button should be active
      expect(descButton).toHaveStyle('background-color: rgb(58, 123, 200)'); // theme.colors.primaryDark

      // Ascending button should be inactive
      expect(ascButton).toHaveStyle('background-color: rgb(245, 245, 245)');
    });

    it('shows proper button colors based on active state', () => {
      renderBeadSort({ field: 'name', direction: 'asc' });

      const ascButton = screen.getByTitle('Sort ascending');
      const descButton = screen.getByTitle('Sort descending');

      // Active button should have white text
      expect(ascButton).toHaveStyle('color: rgb(255, 255, 255)');

      // Inactive button should have text color
      expect(descButton).toHaveStyle('color: rgb(51, 51, 51)'); // theme.colors.text
    });
  });

  describe('Accessibility', () => {
    it('has proper labels for select element', () => {
      renderBeadSort();

      const select = screen.getByLabelText('Sort by:');
      expect(select).toBeInTheDocument();
    });

    it('has proper button types for direction toggles', () => {
      renderBeadSort();

      const ascButton = screen.getByTitle('Sort ascending');
      const descButton = screen.getByTitle('Sort descending');

      expect(ascButton).toHaveAttribute('type', 'button');
      expect(descButton).toHaveAttribute('type', 'button');
    });

    it('has descriptive titles for direction buttons', () => {
      renderBeadSort();

      expect(screen.getByTitle('Sort ascending')).toBeInTheDocument();
      expect(screen.getByTitle('Sort descending')).toBeInTheDocument();
    });

    it('has proper select element accessibility', () => {
      renderBeadSort();

      const select = screen.getByRole('combobox');
      expect(select).toBeInTheDocument();
    });
  });

  describe('Icon Display', () => {
    it('displays up arrow icon in ascending button', () => {
      renderBeadSort();

      const ascButton = screen.getByTitle('Sort ascending');
      const svg = ascButton.querySelector('svg');

      expect(svg).toBeInTheDocument();
      expect(svg).toHaveAttribute('width', '16');
      expect(svg).toHaveAttribute('height', '16');
    });

    it('displays down arrow icon in descending button', () => {
      renderBeadSort();

      const descButton = screen.getByTitle('Sort descending');
      const svg = descButton.querySelector('svg');

      expect(svg).toBeInTheDocument();
      expect(svg).toHaveAttribute('width', '16');
      expect(svg).toHaveAttribute('height', '16');
    });
  });

  describe('Layout and Structure', () => {
    it('renders sort field and direction controls in proper layout', () => {
      renderBeadSort();

      // Should have proper container structure
      const container = screen.getByText('Sort by:').parentElement?.parentElement;
      expect(container).toHaveStyle('display: flex');
      expect(container).toHaveStyle('align-items: center');
    });

    it('groups direction buttons together', () => {
      renderBeadSort();

      const ascButton = screen.getByTitle('Sort ascending');
      const descButton = screen.getByTitle('Sort descending');

      // Both buttons should be in the same parent group
      expect(ascButton.parentElement).toBe(descButton.parentElement);
    });
  });

  describe('All Sort Fields', () => {
    const sortFields = [
      { value: 'name', label: 'Name' },
      { value: 'brand', label: 'Brand' },
      { value: 'created_at', label: 'Date Added' },
      { value: 'updated_at', label: 'Last Updated' },
    ] as const;

    sortFields.forEach(({ value, label }) => {
      it(`handles ${label} sort field correctly`, () => {
        renderBeadSort({ field: value, direction: 'asc' });

        const select = screen.getByRole('combobox');
        expect(select).toHaveValue(value);
        expect(screen.getByText(label)).toBeInTheDocument();
      });
    });
  });

  describe('Direction Combinations', () => {
    const directions = ['asc', 'desc'] as const;
    const fields = ['name', 'brand', 'created_at', 'updated_at'] as const;

    directions.forEach(direction => {
      fields.forEach(field => {
        it(`handles ${field} ${direction} combination correctly`, () => {
          renderBeadSort({ field, direction });

          const select = screen.getByRole('combobox');
          expect(select).toHaveValue(field);

          const activeButton = screen.getByTitle(
            direction === 'asc' ? 'Sort ascending' : 'Sort descending'
          );
          const inactiveButton = screen.getByTitle(
            direction === 'asc' ? 'Sort descending' : 'Sort ascending'
          );

          expect(activeButton).toHaveStyle('background-color: rgb(58, 123, 200)');
          expect(inactiveButton).toHaveStyle('background-color: rgb(245, 245, 245)');
        });
      });
    });
  });

  describe('User Interaction Flows', () => {
    it('handles field change followed by direction change', () => {
      const { rerender } = renderBeadSort({ field: 'name', direction: 'asc' });

      // Change field first
      const select = screen.getByRole('combobox');
      fireEvent.change(select, { target: { value: 'brand' } });

      expect(mockOnChange).toHaveBeenCalledWith({
        field: 'brand',
        direction: 'asc',
      });

      // Reset mock and simulate re-render with new state
      mockOnChange.mockClear();

      rerender(
        <BeadSort
          sort={{ field: 'brand', direction: 'asc' }}
          onChange={mockOnChange}
        />
      );

      const descButton = screen.getByTitle('Sort descending');
      fireEvent.click(descButton);

      expect(mockOnChange).toHaveBeenCalledWith({
        field: 'brand',
        direction: 'desc',
      });
    });

    it('handles direction change followed by field change', () => {
      const { rerender } = renderBeadSort({ field: 'name', direction: 'asc' });

      // Change direction first
      const descButton = screen.getByTitle('Sort descending');
      fireEvent.click(descButton);

      expect(mockOnChange).toHaveBeenCalledWith({
        field: 'name',
        direction: 'desc',
      });

      // Reset mock and simulate re-render with new state
      mockOnChange.mockClear();

      rerender(
        <BeadSort
          sort={{ field: 'name', direction: 'desc' }}
          onChange={mockOnChange}
        />
      );

      const select = screen.getByRole('combobox');
      fireEvent.change(select, { target: { value: 'created_at' } });

      expect(mockOnChange).toHaveBeenCalledWith({
        field: 'created_at',
        direction: 'desc',
      });
    });
  });
}); 
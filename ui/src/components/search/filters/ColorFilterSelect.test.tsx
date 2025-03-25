import { render, screen, fireEvent } from '@testing-library/react';
import ColorFilterSelect from './ColorFilterSelect';
import { vi } from 'vitest';
import useBeadColorsQuery from '../../../hooks/queries/useBeadColorsQuery';
import { createTestWrapper } from '../../../test/testUtils';

// Mock the useBeadColorsQuery hook
vi.mock('../../../hooks/queries/useBeadColorsQuery');

// Use the shared test wrapper
const wrapper = createTestWrapper();

describe('ColorFilterSelect', () => {
  const mockOnChange = vi.fn();

  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('renders with loading state', () => {
    // Mock the hook to return loading state
    (useBeadColorsQuery as jest.Mock).mockReturnValue({
      data: undefined,
      isLoading: true,
    });

    render(<ColorFilterSelect onChange={mockOnChange} value="" />, { wrapper });

    // Check if the select is disabled when loading
    const selectElement = screen.getByLabelText(/color:/i);
    expect(selectElement).toBeDisabled();

    // Should still render the "All" option
    expect(screen.getByText('All')).toBeInTheDocument();
  });

  it('renders with color options', () => {
    // Mock data for the hook
    const mockColors = [
      { id: 1, name: 'Red' },
      { id: 2, name: 'Blue' },
      { id: 3, name: 'Green' },
    ];

    (useBeadColorsQuery as jest.Mock).mockReturnValue({
      data: mockColors,
      isLoading: false,
    });

    render(<ColorFilterSelect onChange={mockOnChange} value="" />, { wrapper });

    // Check if all options are rendered
    expect(screen.getByText('All')).toBeInTheDocument();
    expect(screen.getByText('Red')).toBeInTheDocument();
    expect(screen.getByText('Blue')).toBeInTheDocument();
    expect(screen.getByText('Green')).toBeInTheDocument();

    // Check if the select is enabled
    const selectElement = screen.getByLabelText(/color:/i);
    expect(selectElement).not.toBeDisabled();
  });

  it('calls onChange when a color is selected', () => {
    // Mock data for the hook
    const mockColors = [
      { id: 1, name: 'Red' },
      { id: 2, name: 'Blue' },
    ];

    (useBeadColorsQuery as jest.Mock).mockReturnValue({
      data: mockColors,
      isLoading: false,
    });

    render(<ColorFilterSelect onChange={mockOnChange} value="" />, { wrapper });

    // Get the select element
    const selectElement = screen.getByLabelText(/color:/i);

    // Simulate selecting an option
    fireEvent.change(selectElement, { target: { value: '1' } });

    // Verify that onChange was called
    expect(mockOnChange).toHaveBeenCalled();
  });

  it('displays correct selected value', () => {
    // Mock data for the hook
    const mockColors = [
      { id: 1, name: 'Red' },
      { id: 2, name: 'Blue' },
    ];

    (useBeadColorsQuery as jest.Mock).mockReturnValue({
      data: mockColors,
      isLoading: false,
    });

    render(<ColorFilterSelect onChange={mockOnChange} value="2" />, { wrapper });

    // Check if the correct option is selected
    const selectElement = screen.getByLabelText(/color:/i) as HTMLSelectElement;
    expect(selectElement.value).toBe('2');
  });

  it('renders with empty data', () => {
    // Mock the hook to return empty data
    (useBeadColorsQuery as jest.Mock).mockReturnValue({
      data: [],
      isLoading: false,
    });

    render(<ColorFilterSelect onChange={mockOnChange} value="" />, { wrapper });

    // Should only render the "All" option
    expect(screen.getByText('All')).toBeInTheDocument();

    // Check that no other options are rendered
    const selectElement = screen.getByLabelText(/color:/i);
    expect(selectElement.children.length).toBe(1);
  });

  it('handles disabled state correctly', () => {
    // Mock the hook to return loading state
    (useBeadColorsQuery as jest.Mock).mockReturnValue({
      data: [{ id: 1, name: 'Red' }],
      isLoading: true,
    });

    render(<ColorFilterSelect onChange={mockOnChange} value="" />, { wrapper });

    // Check if the select is disabled when loading
    const selectElement = screen.getByLabelText(/color:/i);
    expect(selectElement).toBeDisabled();

    // Even though we have data, it should still be disabled due to isLoading
    expect(screen.getByText('All')).toBeInTheDocument();
    // The data should still be rendered even though it's loading
    expect(screen.getByText('Red')).toBeInTheDocument();
  });
});

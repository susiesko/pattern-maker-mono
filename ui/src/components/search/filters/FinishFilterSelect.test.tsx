import { ReactNode } from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ThemeProvider } from 'styled-components';
import FinishFilterSelect from './FinishFilterSelect';
import theme from '../../../styles/theme';
import { vi } from 'vitest';
import useBeadFinishesQuery from '../../../hooks/queries/useBeadFinishesQuery';

// Mock the useBeadFinishesQuery hook
vi.mock('../../../hooks/queries/useBeadFinishesQuery');

// Create a wrapper with QueryClientProvider and ThemeProvider
const createWrapper = () => {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: {
        retry: false,
      },
    },
  });

  return ({ children }: { children: ReactNode }) => (
    <QueryClientProvider client={queryClient}>
      <ThemeProvider theme={theme}>{children}</ThemeProvider>
    </QueryClientProvider>
  );
};

describe('FinishFilterSelect', () => {
  const mockOnChange = vi.fn();

  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('renders with loading state', () => {
    // Mock the hook to return loading state
    (useBeadFinishesQuery as jest.Mock).mockReturnValue({
      data: undefined,
      isLoading: true,
    });

    render(<FinishFilterSelect onChange={mockOnChange} value="" />, { wrapper: createWrapper() });

    // Check if the select is disabled when loading
    const selectElement = screen.getByLabelText(/finish:/i);
    expect(selectElement).toBeDisabled();

    // Should still render the "All" option
    expect(screen.getByText('All')).toBeInTheDocument();
  });

  it('renders with finish options', () => {
    // Mock data for the hook - now returns string array
    const mockFinishes = ['Matte', 'Glossy', 'Metallic'];

    (useBeadFinishesQuery as jest.Mock).mockReturnValue({
      data: mockFinishes,
      isLoading: false,
    });

    render(<FinishFilterSelect onChange={mockOnChange} value="" />, { wrapper: createWrapper() });

    // Check if all options are rendered
    expect(screen.getByText('All')).toBeInTheDocument();
    expect(screen.getByText('Matte')).toBeInTheDocument();
    expect(screen.getByText('Glossy')).toBeInTheDocument();
    expect(screen.getByText('Metallic')).toBeInTheDocument();

    // Check if the select is enabled
    const selectElement = screen.getByLabelText(/finish:/i);
    expect(selectElement).not.toBeDisabled();
  });

  it('calls onChange when a finish is selected', () => {
    // Mock data for the hook - now returns string array
    const mockFinishes = ['Matte', 'Glossy'];

    (useBeadFinishesQuery as jest.Mock).mockReturnValue({
      data: mockFinishes,
      isLoading: false,
    });

    render(<FinishFilterSelect onChange={mockOnChange} value="" />, { wrapper: createWrapper() });

    // Get the select element
    const selectElement = screen.getByLabelText(/finish:/i);

    // Simulate selecting an option
    fireEvent.change(selectElement, { target: { value: 'Matte' } });

    // Verify that onChange was called
    expect(mockOnChange).toHaveBeenCalled();
  });

  it('displays correct selected value', () => {
    // Mock data for the hook - now returns string array
    const mockFinishes = ['Matte', 'Glossy'];

    (useBeadFinishesQuery as jest.Mock).mockReturnValue({
      data: mockFinishes,
      isLoading: false,
    });

    render(<FinishFilterSelect onChange={mockOnChange} value="Glossy" />, { wrapper: createWrapper() });

    // Check if the correct option is selected
    const selectElement = screen.getByLabelText(/finish:/i) as HTMLSelectElement;
    expect(selectElement.value).toBe('Glossy');
  });

  it('renders with empty data', () => {
    // Mock the hook to return empty data
    (useBeadFinishesQuery as jest.Mock).mockReturnValue({
      data: [],
      isLoading: false,
    });

    render(<FinishFilterSelect onChange={mockOnChange} value="" />, { wrapper: createWrapper() });

    // Should only render the "All" option
    expect(screen.getByText('All')).toBeInTheDocument();

    // Check that no other options are rendered
    const selectElement = screen.getByLabelText(/finish:/i);
    expect(selectElement.children.length).toBe(1);
  });

  it('handles disabled state correctly', () => {
    // Mock the hook to return loading state
    (useBeadFinishesQuery as jest.Mock).mockReturnValue({
      data: ['Matte'],
      isLoading: true,
    });

    render(<FinishFilterSelect onChange={mockOnChange} value="" />, { wrapper: createWrapper() });

    // Check if the select is disabled when loading
    const selectElement = screen.getByLabelText(/finish:/i);
    expect(selectElement).toBeDisabled();

    // Even though we have data, it should still be disabled due to isLoading
    expect(screen.getByText('All')).toBeInTheDocument();
    // The data should still be rendered even though it's loading
    expect(screen.getByText('Matte')).toBeInTheDocument();
  });
});

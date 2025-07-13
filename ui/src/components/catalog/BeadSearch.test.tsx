import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { vi } from 'vitest';
import BeadSearch from './BeadSearch';
import { createTestWrapper } from '../../test/testUtils';

describe('BeadSearch', () => {
  const mockOnChange = vi.fn();

  beforeEach(() => {
    vi.clearAllMocks();
    vi.useFakeTimers();
  });

  afterEach(() => {
    vi.runOnlyPendingTimers();
    vi.clearAllTimers();
    vi.useRealTimers();
  });

  const renderBeadSearch = (props = {}) => {
    const defaultProps = {
      value: '',
      onChange: mockOnChange,
      ...props,
    };

    return render(
      <BeadSearch {...defaultProps} />,
      { wrapper: createTestWrapper() }
    );
  };

  describe('Rendering', () => {
    it('renders search input with default placeholder', () => {
      renderBeadSearch();

      const input = screen.getByPlaceholderText('Search beads...');
      expect(input).toBeInTheDocument();
      expect(input).toHaveValue('');
    });

    it('renders search input with custom placeholder', () => {
      renderBeadSearch({ placeholder: 'Custom placeholder' });

      const input = screen.getByPlaceholderText('Custom placeholder');
      expect(input).toBeInTheDocument();
    });

    it('renders search icon', () => {
      renderBeadSearch();

      const searchIcon = screen.getByRole('textbox').previousSibling;
      expect(searchIcon).toBeInTheDocument();
    });

    it('displays initial value', () => {
      renderBeadSearch({ value: 'initial search' });

      const input = screen.getByDisplayValue('initial search');
      expect(input).toBeInTheDocument();
    });
  });

  describe('Search Input Behavior', () => {
    it('updates input value immediately when typing', () => {
      renderBeadSearch();

      const input = screen.getByRole('textbox');
      fireEvent.change(input, { target: { value: 'test search' } });

      expect(input).toHaveValue('test search');
    });

    it.skip('calls onChange after debounce delay', () => {
      renderBeadSearch();

      const input = screen.getByRole('textbox');
      fireEvent.change(input, { target: { value: 'test' } });

      // Should not call onChange immediately
      expect(mockOnChange).not.toHaveBeenCalled();

      // Advance timers by debounce delay
      vi.advanceTimersByTime(300);

      expect(mockOnChange).toHaveBeenCalledWith('test');
    });

    it.skip('debounces multiple rapid changes', () => {
      renderBeadSearch();

      const input = screen.getByRole('textbox');

      // Make multiple rapid changes
      fireEvent.change(input, { target: { value: 'a' } });
      fireEvent.change(input, { target: { value: 'ab' } });
      fireEvent.change(input, { target: { value: 'abc' } });

      // Should not call onChange yet
      expect(mockOnChange).not.toHaveBeenCalled();

      // Advance timers by debounce delay
      vi.advanceTimersByTime(300);

      // Should only call onChange once with the final value
      expect(mockOnChange).toHaveBeenCalledTimes(1);
      expect(mockOnChange).toHaveBeenCalledWith('abc');
    });

    it.skip('uses default debounce delay of 300ms', () => {
      renderBeadSearch();

      const input = screen.getByRole('textbox');
      fireEvent.change(input, { target: { value: 'test' } });

      // Should not call onChange before 300ms
      vi.advanceTimersByTime(299);
      expect(mockOnChange).not.toHaveBeenCalled();

      // Should call onChange after 300ms
      vi.advanceTimersByTime(1);
      expect(mockOnChange).toHaveBeenCalledWith('test');
    });
  });

  describe('Clear Functionality', () => {
    it('shows clear button when input has value', () => {
      renderBeadSearch({ value: 'test search' });

      const clearButton = screen.getByRole('button');
      expect(clearButton).toBeInTheDocument();
    });

    it('does not show clear button when input is empty', () => {
      renderBeadSearch({ value: '' });

      const clearButton = screen.queryByRole('button');
      expect(clearButton).not.toBeInTheDocument();
    });

    it.skip('clears input when clear button is clicked', () => {
      renderBeadSearch({ value: 'test' });

      const clearButton = screen.getByTitle('Clear search');
      fireEvent.click(clearButton);

      expect(mockOnChange).toHaveBeenCalledWith('');
    });

    it('shows and hides clear button based on input value', () => {
      const { rerender } = renderBeadSearch({ value: '' });

      // Should not show clear button for empty input
      expect(screen.queryByRole('button')).not.toBeInTheDocument();

      // Re-render with value
      rerender(
        <BeadSearch value="test" onChange={mockOnChange} />
      );

      // Should show clear button for non-empty input
      expect(screen.getByRole('button')).toBeInTheDocument();
    });
  });

  describe('Value Synchronization', () => {
    it('updates input value when value prop changes', () => {
      const { rerender } = renderBeadSearch({ value: 'initial' });

      let input = screen.getByDisplayValue('initial');
      expect(input).toBeInTheDocument();

      // Change the value prop
      rerender(
        <BeadSearch
          value="updated"
          onChange={mockOnChange}
        />
      );

      input = screen.getByDisplayValue('updated');
      expect(input).toBeInTheDocument();
    });

    it('maintains input state independently when typing', () => {
      renderBeadSearch({ value: 'initial' });

      const input = screen.getByRole('textbox');

      // User types something different
      fireEvent.change(input, { target: { value: 'user typed' } });

      expect(input).toHaveValue('user typed');
    });
  });

  describe('Accessibility', () => {
    it('has proper input type', () => {
      renderBeadSearch();

      const input = screen.getByRole('textbox');
      expect(input).toHaveAttribute('type', 'text');
    });

    it('has accessible clear button', () => {
      renderBeadSearch({ value: 'test' });

      const clearButton = screen.getByRole('button');
      expect(clearButton).toHaveAttribute('type', 'button');
    });
  });

  describe('Edge Cases', () => {
    it.skip('handles empty string input', () => {
      renderBeadSearch();

      const input = screen.getByRole('textbox');
      fireEvent.change(input, { target: { value: '' } });

      vi.advanceTimersByTime(300);

      expect(mockOnChange).toHaveBeenCalledWith('');
    });

    it.skip('handles special characters in input', () => {
      renderBeadSearch();

      const input = screen.getByRole('textbox');
      fireEvent.change(input, { target: { value: '@#$%' } });

      vi.advanceTimersByTime(300);

      expect(mockOnChange).toHaveBeenCalledWith('@#$%');
    });

    it('cleans up timeout on unmount', () => {
      const { unmount } = renderBeadSearch();

      const input = screen.getByRole('textbox');
      fireEvent.change(input, { target: { value: 'test' } });

      // Unmount before debounce completes
      unmount();

      // Fast-forward time
      vi.advanceTimersByTime(300);

      // Should not call onChange after unmount
      expect(mockOnChange).not.toHaveBeenCalled();
    });
  });
}); 
import { render, screen, fireEvent } from '@testing-library/react';
import { vi } from 'vitest';
import ErrorMessage from './ErrorMessage';
import { createTestWrapper } from '../../test/testUtils';

describe('ErrorMessage', () => {
  const mockOnRetry = vi.fn();

  beforeEach(() => {
    vi.clearAllMocks();
  });

  const renderErrorMessage = (props = {}) => {
    const defaultProps = {
      message: 'Something went wrong',
      ...props,
    };

    return render(
      <ErrorMessage {...defaultProps} />,
      { wrapper: createTestWrapper() }
    );
  };

  describe('Rendering', () => {
    it('renders error message', () => {
      renderErrorMessage({ message: 'Test error message' });

      expect(screen.getByText('Test error message')).toBeInTheDocument();
    });

    it('renders error icon', () => {
      renderErrorMessage();

      const svg = document.querySelector('svg');
      expect(svg).toBeInTheDocument();
      expect(svg?.tagName).toBe('svg');
    });

    it('displays message with proper styling', () => {
      renderErrorMessage({ message: 'Error message' });

      const message = screen.getByText('Error message');
      expect(message).toHaveStyle('max-width: 400px');
      expect(message).toHaveStyle('margin: 0');
    });
  });

  describe('Retry Functionality', () => {
    it('shows retry button when onRetry is provided', () => {
      renderErrorMessage({ onRetry: mockOnRetry });

      const retryButton = screen.getByText('Try Again');
      expect(retryButton).toBeInTheDocument();
      expect(retryButton).toHaveAttribute('type', 'button');
    });

    it('does not show retry button when onRetry is not provided', () => {
      renderErrorMessage();

      const retryButton = screen.queryByText('Try Again');
      expect(retryButton).not.toBeInTheDocument();
    });

    it('calls onRetry when retry button is clicked', () => {
      renderErrorMessage({ onRetry: mockOnRetry });

      const retryButton = screen.getByText('Try Again');
      fireEvent.click(retryButton);

      expect(mockOnRetry).toHaveBeenCalledTimes(1);
    });

    it('uses custom retry label when provided', () => {
      renderErrorMessage({
        onRetry: mockOnRetry,
        retryLabel: 'Reload Data'
      });

      const retryButton = screen.getByText('Reload Data');
      expect(retryButton).toBeInTheDocument();
      expect(screen.queryByText('Try Again')).not.toBeInTheDocument();
    });

    it('handles multiple retry button clicks', () => {
      renderErrorMessage({ onRetry: mockOnRetry });

      const retryButton = screen.getByText('Try Again');
      fireEvent.click(retryButton);
      fireEvent.click(retryButton);
      fireEvent.click(retryButton);

      expect(mockOnRetry).toHaveBeenCalledTimes(3);
    });
  });

  describe('Accessibility', () => {
    it('has proper container structure', () => {
      renderErrorMessage();

      const container = screen.getByText('Something went wrong').parentElement;
      expect(container).toHaveStyle('display: flex');
      expect(container).toHaveStyle('flex-direction: column');
      expect(container).toHaveStyle('align-items: center');
      expect(container).toHaveStyle('text-align: center');
    });

    it('has proper button role for retry button', () => {
      renderErrorMessage({ onRetry: mockOnRetry });

      const retryButton = screen.getByRole('button', { name: 'Try Again' });
      expect(retryButton).toBeInTheDocument();
    });

    it('has proper button type for retry button', () => {
      renderErrorMessage({ onRetry: mockOnRetry });

      const retryButton = screen.getByText('Try Again');
      expect(retryButton).toHaveAttribute('type', 'button');
    });
  });

  describe('Layout and Spacing', () => {
    it('renders icon above message', () => {
      renderErrorMessage();

      const container = screen.getByText('Something went wrong').parentElement;
      const children = Array.from(container?.children || []);

      // Icon should be first, message second
      expect(children.length).toBeGreaterThanOrEqual(2);

      const iconContainer = children[0];
      const messageElement = children[1];

      expect(iconContainer.querySelector('svg')).toBeInTheDocument();
      expect(messageElement.textContent).toBe('Something went wrong');
    });

    it('renders retry button last when present', () => {
      renderErrorMessage({ onRetry: mockOnRetry });

      const container = screen.getByText('Something went wrong').parentElement;
      const children = Array.from(container?.children || []);

      // Should have icon, message, and button
      expect(children.length).toBe(3);

      const lastChild = children[children.length - 1];
      expect(lastChild.textContent).toBe('Try Again');
    });
  });

  describe('Different Error Messages', () => {
    it('handles long error messages', () => {
      const longMessage = 'This is a very long error message that should still be displayed properly and wrap nicely within the container without breaking the layout or causing overflow issues.';
      renderErrorMessage({ message: longMessage });

      expect(screen.getByText(longMessage)).toBeInTheDocument();
    });

    it('handles short error messages', () => {
      renderErrorMessage({ message: 'Error' });

      expect(screen.getByText('Error')).toBeInTheDocument();
    });

    it('handles error messages with special characters', () => {
      const messageWithSpecialChars = 'Error: Failed to load data! Please try again...';
      renderErrorMessage({ message: messageWithSpecialChars });

      expect(screen.getByText(messageWithSpecialChars)).toBeInTheDocument();
    });

    it('handles empty error message', () => {
      renderErrorMessage({ message: '' });

      const messageElement = screen.getByRole('paragraph');
      expect(messageElement).toBeInTheDocument();
      expect(messageElement.textContent).toBe('');
    });
  });

  describe('Component Variants', () => {
    it('renders error-only variant correctly', () => {
      renderErrorMessage({
        message: 'Network error occurred',
      });

      expect(screen.getByText('Network error occurred')).toBeInTheDocument();
      expect(screen.queryByRole('button')).not.toBeInTheDocument();
    });

    it('renders error-with-retry variant correctly', () => {
      renderErrorMessage({
        message: 'Failed to load data',
        onRetry: mockOnRetry,
        retryLabel: 'Refresh',
      });

      expect(screen.getByText('Failed to load data')).toBeInTheDocument();
      expect(screen.getByText('Refresh')).toBeInTheDocument();
    });
  });

  describe('Props Validation', () => {
    it('handles undefined onRetry gracefully', () => {
      renderErrorMessage({ onRetry: undefined });

      expect(screen.queryByRole('button')).not.toBeInTheDocument();
    });

    it('handles undefined retryLabel with defined onRetry', () => {
      renderErrorMessage({
        onRetry: mockOnRetry,
        retryLabel: undefined
      });

      expect(screen.getByText('Try Again')).toBeInTheDocument(); // Uses default
    });
  });
}); 
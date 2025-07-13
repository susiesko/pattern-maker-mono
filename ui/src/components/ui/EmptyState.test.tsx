import { render, screen, fireEvent } from '@testing-library/react';
import { vi } from 'vitest';
import EmptyState from './EmptyState';
import { createTestWrapper } from '../../test/testUtils';

describe('EmptyState', () => {
  const mockOnAction = vi.fn();

  beforeEach(() => {
    vi.clearAllMocks();
  });

  const renderEmptyState = (props = {}) => {
    const defaultProps = {
      title: 'No Data Found',
      message: 'There is no data to display',
      ...props,
    };

    return render(
      <EmptyState {...defaultProps} />,
      { wrapper: createTestWrapper() }
    );
  };

  describe('Rendering', () => {
    it('renders title and message', () => {
      renderEmptyState({
        title: 'No Beads Found',
        message: 'Try adjusting your search criteria',
      });

      expect(screen.getByText('No Beads Found')).toBeInTheDocument();
      expect(screen.getByText('Try adjusting your search criteria')).toBeInTheDocument();
    });

    it('renders default icon when no custom icon provided', () => {
      renderEmptyState();

      const svg = document.querySelector('svg');
      expect(svg).toBeInTheDocument();
      expect(svg?.tagName).toBe('svg');
      expect(svg).toHaveAttribute('width', '64');
      expect(svg).toHaveAttribute('height', '64');
    });

    it('renders custom icon when provided', () => {
      const customIcon = <div data-testid="custom-icon">Custom Icon</div>;
      renderEmptyState({ icon: customIcon });

      expect(screen.getByTestId('custom-icon')).toBeInTheDocument();
    });

    it('displays proper heading hierarchy', () => {
      renderEmptyState();

      const title = screen.getByText('No Data Found');
      expect(title.tagName).toBe('H3');
    });
  });

  describe('Action Button', () => {
    it('shows action button when onAction and actionLabel are provided', () => {
      renderEmptyState({
        onAction: mockOnAction,
        actionLabel: 'Add New Item',
      });

      const actionButton = screen.getByText('Add New Item');
      expect(actionButton).toBeInTheDocument();
      expect(actionButton).toHaveAttribute('type', 'button');
    });

    it('does not show action button when onAction is not provided', () => {
      renderEmptyState({
        actionLabel: 'Add New Item',
      });

      expect(screen.queryByText('Add New Item')).not.toBeInTheDocument();
    });

    it('does not show action button when actionLabel is not provided', () => {
      renderEmptyState({
        onAction: mockOnAction,
      });

      expect(screen.queryByRole('button')).not.toBeInTheDocument();
    });

    it('calls onAction when action button is clicked', () => {
      renderEmptyState({
        onAction: mockOnAction,
        actionLabel: 'Add Item',
      });

      const actionButton = screen.getByText('Add Item');
      fireEvent.click(actionButton);

      expect(mockOnAction).toHaveBeenCalledTimes(1);
    });

    it('handles multiple button clicks', () => {
      renderEmptyState({
        onAction: mockOnAction,
        actionLabel: 'Retry',
      });

      const actionButton = screen.getByText('Retry');
      fireEvent.click(actionButton);
      fireEvent.click(actionButton);

      expect(mockOnAction).toHaveBeenCalledTimes(2);
    });
  });

  describe('Different Content Scenarios', () => {
    it('handles empty search results scenario', () => {
      renderEmptyState({
        title: 'No Results Found',
        message: 'Try adjusting your search filters or search terms.',
        actionLabel: 'Clear Filters',
        onAction: mockOnAction,
      });

      expect(screen.getByText('No Results Found')).toBeInTheDocument();
      expect(screen.getByText('Try adjusting your search filters or search terms.')).toBeInTheDocument();
      expect(screen.getByText('Clear Filters')).toBeInTheDocument();
    });

    it('handles first-time user scenario', () => {
      renderEmptyState({
        title: 'Welcome to Your Catalog',
        message: 'Start building your bead collection by adding your first bead.',
        actionLabel: 'Add First Bead',
        onAction: mockOnAction,
      });

      expect(screen.getByText('Welcome to Your Catalog')).toBeInTheDocument();
      expect(screen.getByText('Start building your bead collection by adding your first bead.')).toBeInTheDocument();
      expect(screen.getByText('Add First Bead')).toBeInTheDocument();
    });

    it('handles error recovery scenario', () => {
      renderEmptyState({
        title: 'Connection Lost',
        message: 'We couldn\'t load your data. Please check your connection.',
        actionLabel: 'Retry Connection',
        onAction: mockOnAction,
      });

      expect(screen.getByText('Connection Lost')).toBeInTheDocument();
      expect(screen.getByText('We couldn\'t load your data. Please check your connection.')).toBeInTheDocument();
      expect(screen.getByText('Retry Connection')).toBeInTheDocument();
    });
  });

  describe('Accessibility', () => {
    it('has proper container structure', () => {
      renderEmptyState();

      const container = screen.getByText('No Data Found').parentElement;
      expect(container).toHaveStyle('display: flex');
      expect(container).toHaveStyle('flex-direction: column');
      expect(container).toHaveStyle('align-items: center');
      expect(container).toHaveStyle('text-align: center');
    });

    it('has proper button role for action button', () => {
      renderEmptyState({
        onAction: mockOnAction,
        actionLabel: 'Take Action',
      });

      const actionButton = screen.getByRole('button', { name: 'Take Action' });
      expect(actionButton).toBeInTheDocument();
    });

    it('has proper heading structure', () => {
      renderEmptyState();

      const heading = screen.getByRole('heading', { level: 3 });
      expect(heading).toHaveTextContent('No Data Found');
    });

    it('has accessible button type', () => {
      renderEmptyState({
        onAction: mockOnAction,
        actionLabel: 'Action',
      });

      const actionButton = screen.getByText('Action');
      expect(actionButton).toHaveAttribute('type', 'button');
    });
  });

  describe('Layout and Spacing', () => {
    it('renders components in correct order', () => {
      renderEmptyState({
        onAction: mockOnAction,
        actionLabel: 'Do Something',
      });

      const container = screen.getByText('No Data Found').parentElement;
      const children = Array.from(container?.children || []);

      expect(children.length).toBe(4); // icon, title, message, button

      // Check order: icon, title, message, button
      const iconContainer = children[0];
      const titleElement = children[1];
      const messageElement = children[2];
      const buttonElement = children[3];

      expect(iconContainer.querySelector('svg')).toBeInTheDocument();
      expect(titleElement.textContent).toBe('No Data Found');
      expect(messageElement.textContent).toBe('There is no data to display');
      expect(buttonElement.textContent).toBe('Do Something');
    });

    it('renders without action button when not provided', () => {
      renderEmptyState();

      const container = screen.getByText('No Data Found').parentElement;
      const children = Array.from(container?.children || []);

      expect(children.length).toBe(3); // icon, title, message only
    });
  });

  describe('Content Validation', () => {
    it('handles long titles', () => {
      const longTitle = 'This is a very long title that should still display properly';
      renderEmptyState({ title: longTitle });

      expect(screen.getByText(longTitle)).toBeInTheDocument();
    });

    it('handles long messages', () => {
      const longMessage = 'This is a very long message that explains the empty state in great detail and should wrap properly within the container without causing layout issues or overflow problems.';
      renderEmptyState({ message: longMessage });

      expect(screen.getByText(longMessage)).toBeInTheDocument();
    });

    it('handles special characters in content', () => {
      renderEmptyState({
        title: 'No Data! 🎨',
        message: 'Try searching for "beads" or "patterns"...',
        actionLabel: 'Let\'s Go!',
        onAction: mockOnAction,
      });

      expect(screen.getByText('No Data! 🎨')).toBeInTheDocument();
      expect(screen.getByText('Try searching for "beads" or "patterns"...')).toBeInTheDocument();
      expect(screen.getByText('Let\'s Go!')).toBeInTheDocument();
    });
  });

  describe('Custom Icon Handling', () => {
    it('renders React element as custom icon', () => {
      const customIcon = (
        <div data-testid="react-icon">
          <span>📦</span>
        </div>
      );
      renderEmptyState({ icon: customIcon });

      expect(screen.getByTestId('react-icon')).toBeInTheDocument();
      expect(screen.getByText('📦')).toBeInTheDocument();
    });

    it('renders SVG as custom icon', () => {
      const customSvg = (
        <svg data-testid="custom-svg" width="32" height="32">
          <circle cx="16" cy="16" r="8" fill="blue" />
        </svg>
      );
      renderEmptyState({ icon: customSvg });

      expect(screen.getByTestId('custom-svg')).toBeInTheDocument();
    });
  });

  describe('Props Validation', () => {
    it('handles undefined onAction gracefully', () => {
      renderEmptyState({
        onAction: undefined,
        actionLabel: 'Action',
      });

      expect(screen.queryByText('Action')).not.toBeInTheDocument();
    });

    it('handles undefined actionLabel gracefully', () => {
      renderEmptyState({
        onAction: mockOnAction,
        actionLabel: undefined,
      });

      expect(screen.queryByRole('button')).not.toBeInTheDocument();
    });

    it('handles undefined icon gracefully', () => {
      renderEmptyState({ icon: undefined });

      // Should render default icon
      const svg = document.querySelector('svg');
      expect(svg).toBeInTheDocument();
    });
  });
}); 
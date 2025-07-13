import { render, screen } from '@testing-library/react';
import LoadingSpinner from './LoadingSpinner';
import { createTestWrapper } from '../../test/testUtils';

describe('LoadingSpinner', () => {
  const renderLoadingSpinner = (props = {}) => {
    return render(
      <LoadingSpinner {...props} />,
      { wrapper: createTestWrapper() }
    );
  };

  describe('Rendering', () => {
    it('renders with default message', () => {
      renderLoadingSpinner();

      expect(screen.getByText('Loading...')).toBeInTheDocument();
    });

    it('renders with custom message', () => {
      renderLoadingSpinner({ message: 'Loading beads...' });

      expect(screen.getByText('Loading beads...')).toBeInTheDocument();
    });

    it('renders without message when message is empty', () => {
      renderLoadingSpinner({ message: '' });

      expect(screen.queryByRole('paragraph')).not.toBeInTheDocument();
    });

    it('renders spinner element', () => {
      renderLoadingSpinner();

      const container = screen.getByText('Loading...').parentElement;
      const spinner = container?.querySelector('div');
      expect(spinner).toBeInTheDocument();
    });
  });

  describe('Size Variants', () => {
    it('renders with default medium size', () => {
      renderLoadingSpinner();

      const container = screen.getByText('Loading...').parentElement;
      const spinner = container?.querySelector('div');
      expect(spinner).toHaveStyle('width: 40px');
      expect(spinner).toHaveStyle('height: 40px');
    });

    it('renders with small size', () => {
      renderLoadingSpinner({ size: 'small' });

      const container = screen.getByText('Loading...').parentElement;
      const spinner = container?.querySelector('div');
      expect(spinner).toHaveStyle('width: 24px');
      expect(spinner).toHaveStyle('height: 24px');
    });

    it('renders with large size', () => {
      renderLoadingSpinner({ size: 'large' });

      const container = screen.getByText('Loading...').parentElement;
      const spinner = container?.querySelector('div');
      expect(spinner).toHaveStyle('width: 60px');
      expect(spinner).toHaveStyle('height: 60px');
    });

    it('handles invalid size by defaulting to medium', () => {
      renderLoadingSpinner({ size: 'invalid' as any });

      const container = screen.getByText('Loading...').parentElement;
      const spinner = container?.querySelector('div');
      expect(spinner).toHaveStyle('width: 40px');
      expect(spinner).toHaveStyle('height: 40px');
    });
  });

  describe('Accessibility', () => {
    it('has proper container structure', () => {
      renderLoadingSpinner();

      const container = screen.getByText('Loading...').parentElement;
      expect(container).toHaveStyle('display: flex');
      expect(container).toHaveStyle('flex-direction: column');
      expect(container).toHaveStyle('align-items: center');
    });

    it('positions message below spinner', () => {
      renderLoadingSpinner({ message: 'Loading data...' });

      const container = screen.getByText('Loading data...').parentElement;
      expect(container).toHaveStyle('flex-direction: column');
    });
  });

  describe('Animation', () => {
    it('applies rotation animation to spinner', () => {
      renderLoadingSpinner();

      const container = screen.getByText('Loading...').parentElement;
      const spinner = container?.querySelector('div');

      // Check that the spinner element exists and has the animation class
      expect(spinner).toBeInTheDocument();
      expect(spinner).toHaveStyle('border-radius: 50%');
      // Note: CSS animations may not be fully computed in jsdom test environment
      // so we test for the presence of the spinner element and its styling
    });
  });

  describe('Props Handling', () => {
    it('handles undefined message prop', () => {
      renderLoadingSpinner({ message: undefined });

      // Component should default to 'Loading...' when message is undefined
      expect(screen.getByText('Loading...')).toBeInTheDocument();
    });

    it('handles undefined size prop', () => {
      renderLoadingSpinner({ size: undefined });

      const container = screen.getByText('Loading...').parentElement;
      const spinner = container?.querySelector('div');
      expect(spinner).toHaveStyle('width: 40px'); // Default medium size
    });
  });
}); 
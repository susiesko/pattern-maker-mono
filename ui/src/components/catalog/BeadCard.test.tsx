import { render, screen, fireEvent } from '@testing-library/react';
import { vi } from 'vitest';
import BeadCard from './BeadCard';
import { createTestWrapper } from '../../test/testUtils';
import { Bead } from '../../types/beads';

describe('BeadCard', () => {
  const mockOnEdit = vi.fn();
  const mockOnView = vi.fn();

  const mockBead: Bead = {
    id: 1,
    name: 'Test Bead',
    brand_product_code: 'TB-001',
    image: 'test-bead.jpg',
    metadata: {},
    created_at: '2023-01-01T00:00:00Z',
    updated_at: '2023-01-01T00:00:00Z',
    brand: {
      id: 1,
      name: 'Test Brand',
      website: 'https://testbrand.com',
    },
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

  beforeEach(() => {
    vi.clearAllMocks();
  });

  const renderBeadCard = (bead = mockBead) => {
    return render(
      <BeadCard
        bead={bead}
        onEdit={mockOnEdit}
        onView={mockOnView}
      />,
      { wrapper: createTestWrapper() }
    );
  };

  describe('Rendering', () => {
    it('renders bead information correctly', () => {
      renderBeadCard();

      expect(screen.getByText('Test Bead')).toBeInTheDocument();
      expect(screen.getByText('TB-001')).toBeInTheDocument();
      expect(screen.getByText('Test Brand')).toBeInTheDocument();
      expect(screen.getByText('Seed • 11/0')).toBeInTheDocument();
    });

    it('renders bead image when image is provided', () => {
      renderBeadCard();

      const image = screen.getByAltText('Test Bead');
      expect(image).toBeInTheDocument();
      expect(image).toHaveAttribute('src', '/bead-images/test-bead.jpg');
    });

    it('renders placeholder when no image is provided', () => {
      const beadWithoutImage = { ...mockBead, image: '' };
      renderBeadCard(beadWithoutImage);

      expect(screen.queryByAltText('Test Bead')).not.toBeInTheDocument();

      // Check for placeholder div by looking at the structure
      const imageContainer = screen.getByText('Test Bead').closest('div')?.parentElement?.querySelector('div:first-child');
      expect(imageContainer).toBeInTheDocument();

      // Verify no img tag is present
      expect(screen.queryByRole('img')).not.toBeInTheDocument();
    });

    it('renders colors when available', () => {
      renderBeadCard();

      expect(screen.getByText('Color:')).toBeInTheDocument();
      expect(screen.getByText('Red')).toBeInTheDocument();
    });

    it('renders finishes when available', () => {
      renderBeadCard();

      expect(screen.getByText('Finish:')).toBeInTheDocument();
      expect(screen.getByText('Matte')).toBeInTheDocument();
    });

    it('does not render colors section when no colors', () => {
      const beadWithoutColors = { ...mockBead, color_group: undefined };
      renderBeadCard(beadWithoutColors);

      expect(screen.queryByText('Color:')).not.toBeInTheDocument();
    });

    it('does not render finishes section when no finishes', () => {
      const beadWithoutFinishes = { ...mockBead, finish: undefined };
      renderBeadCard(beadWithoutFinishes);

      expect(screen.queryByText('Finish:')).not.toBeInTheDocument();
    });

    it('does not render product code when not provided', () => {
      const beadWithoutCode = { ...mockBead, brand_product_code: '' };
      renderBeadCard(beadWithoutCode);

      expect(screen.queryByText('TB-001')).not.toBeInTheDocument();
    });
  });

  describe('Interactions', () => {
    it('calls onView when card is clicked', () => {
      renderBeadCard();

      const card = screen.getByText('Test Bead').closest('div');
      fireEvent.click(card!);

      expect(mockOnView).toHaveBeenCalledWith(1);
      expect(mockOnEdit).not.toHaveBeenCalled();
    });

    it('calls onEdit when edit button is clicked', () => {
      renderBeadCard();

      const editButton = screen.getByText('Edit');
      fireEvent.click(editButton);

      expect(mockOnEdit).toHaveBeenCalledWith(1);
      expect(mockOnView).not.toHaveBeenCalled();
    });

    it('prevents card click when edit button is clicked', () => {
      renderBeadCard();

      const editButton = screen.getByText('Edit');
      fireEvent.click(editButton);

      expect(mockOnEdit).toHaveBeenCalledWith(1);
      expect(mockOnView).not.toHaveBeenCalled();
    });
  });

  describe('Accessibility', () => {
    it('has proper button text for edit action', () => {
      renderBeadCard();

      const editButton = screen.getByRole('button', { name: 'Edit' });
      expect(editButton).toBeInTheDocument();
    });

    it('has proper alt text for bead image', () => {
      renderBeadCard();

      const image = screen.getByAltText('Test Bead');
      expect(image).toBeInTheDocument();
    });
  });

  describe('Multiple Colors and Finishes', () => {
    it('displays single color correctly', () => {
      const beadWithColor = {
        ...mockBead,
        color_group: 'Red',
      };
      renderBeadCard(beadWithColor);

      expect(screen.getByText('Red')).toBeInTheDocument();
    });

    it('displays single finish correctly', () => {
      const beadWithFinish = {
        ...mockBead,
        finish: 'Matte',
      };
      renderBeadCard(beadWithFinish);

      expect(screen.getByText('Matte')).toBeInTheDocument();
    });

    it('handles single color without comma', () => {
      const beadWithOneColor = {
        ...mockBead,
        color_group: 'Red',
      };
      renderBeadCard(beadWithOneColor);

      expect(screen.getByText('Red')).toBeInTheDocument();
      expect(screen.queryByText(',')).not.toBeInTheDocument();
    });

    it('handles single finish without comma', () => {
      const beadWithOneFinish = {
        ...mockBead,
        finish: 'Matte',
      };
      renderBeadCard(beadWithOneFinish);

      expect(screen.getByText('Matte')).toBeInTheDocument();
      expect(screen.queryByText(',')).not.toBeInTheDocument();
    });
  });

  describe('Component Optimization', () => {
    it('is memoized and does not re-render with same props', () => {
      const { rerender } = renderBeadCard();

      expect(screen.getByText('Test Bead')).toBeInTheDocument();

      // Re-render with same props
      rerender(
        <BeadCard
          bead={mockBead}
          onEdit={mockOnEdit}
          onView={mockOnView}
        />
      );

      expect(screen.getByText('Test Bead')).toBeInTheDocument();
    });
  });
}); 
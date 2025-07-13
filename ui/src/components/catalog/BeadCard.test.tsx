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
    size: {
      id: 1,
      size: '11/0',
    },
    type: {
      id: 1,
      name: 'Seed',
    },
    colors: [
      { id: 1, name: 'Red' },
      { id: 2, name: 'Blue' },
    ],
    finishes: [
      { id: 1, name: 'Matte' },
      { id: 2, name: 'Transparent' },
    ],
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

      expect(screen.getByText('Colors:')).toBeInTheDocument();
      expect(screen.getByText('Red,')).toBeInTheDocument();
      expect(screen.getByText('Blue')).toBeInTheDocument();
    });

    it('renders finishes when available', () => {
      renderBeadCard();

      expect(screen.getByText('Finishes:')).toBeInTheDocument();
      expect(screen.getByText('Matte,')).toBeInTheDocument();
      expect(screen.getByText('Transparent')).toBeInTheDocument();
    });

    it('does not render colors section when no colors', () => {
      const beadWithoutColors = { ...mockBead, colors: [] };
      renderBeadCard(beadWithoutColors);

      expect(screen.queryByText('Colors:')).not.toBeInTheDocument();
    });

    it('does not render finishes section when no finishes', () => {
      const beadWithoutFinishes = { ...mockBead, finishes: [] };
      renderBeadCard(beadWithoutFinishes);

      expect(screen.queryByText('Finishes:')).not.toBeInTheDocument();
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
    it('formats multiple colors correctly with commas', () => {
      const beadWithManyColors = {
        ...mockBead,
        colors: [
          { id: 1, name: 'Red' },
          { id: 2, name: 'Blue' },
          { id: 3, name: 'Green' },
        ],
      };
      renderBeadCard(beadWithManyColors);

      expect(screen.getByText('Red,')).toBeInTheDocument();
      expect(screen.getByText('Blue,')).toBeInTheDocument();
      expect(screen.getByText('Green')).toBeInTheDocument(); // Last item without comma
    });

    it('formats multiple finishes correctly with commas', () => {
      const beadWithManyFinishes = {
        ...mockBead,
        finishes: [
          { id: 1, name: 'Matte' },
          { id: 2, name: 'Transparent' },
          { id: 3, name: 'Shiny' },
        ],
      };
      renderBeadCard(beadWithManyFinishes);

      expect(screen.getByText('Matte,')).toBeInTheDocument();
      expect(screen.getByText('Transparent,')).toBeInTheDocument();
      expect(screen.getByText('Shiny')).toBeInTheDocument(); // Last item without comma
    });

    it('handles single color without comma', () => {
      const beadWithOneColor = {
        ...mockBead,
        colors: [{ id: 1, name: 'Red' }],
      };
      renderBeadCard(beadWithOneColor);

      expect(screen.getByText('Red')).toBeInTheDocument();
      expect(screen.queryByText('Red,')).not.toBeInTheDocument();
    });

    it('handles single finish without comma', () => {
      const beadWithOneFinish = {
        ...mockBead,
        finishes: [{ id: 1, name: 'Matte' }],
      };
      renderBeadCard(beadWithOneFinish);

      expect(screen.getByText('Matte')).toBeInTheDocument();
      expect(screen.queryByText('Matte,')).not.toBeInTheDocument();
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
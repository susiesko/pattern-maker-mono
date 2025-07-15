import { render, screen, fireEvent } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import Pagination from './Pagination';

describe('Pagination', () => {
  const defaultProps = {
    currentPage: 1,
    totalPages: 10,
    onPageChange: vi.fn(),
    hasMore: true,
    loading: false,
    itemsPerPage: 12,
    totalItems: 200
  };

  describe('renders pagination buttons', () => {
    it('renders previous and next buttons', () => {
      render(<Pagination {...defaultProps} />);
      
      expect(screen.getByText('Previous')).toBeInTheDocument();
      expect(screen.getByText('Next')).toBeInTheDocument();
    });

    it('renders page numbers', () => {
      render(<Pagination {...defaultProps} />);
      
      expect(screen.getByText('1')).toBeInTheDocument();
      expect(screen.getByText('2')).toBeInTheDocument();
      expect(screen.getByText('3')).toBeInTheDocument();
    });

    it('shows pagination info', () => {
      render(<Pagination {...defaultProps} />);
      
      expect(screen.getByText(/Showing 1 to 12 of 200 items/)).toBeInTheDocument();
    });
  });

  describe('page size selector', () => {
    it('renders page size selector when onPageSizeChange is provided', () => {
      const onPageSizeChange = vi.fn();
      render(
        <Pagination 
          {...defaultProps} 
          onPageSizeChange={onPageSizeChange}
          itemsPerPage={12}
        />
      );
      
      expect(screen.getByText('Show:')).toBeInTheDocument();
      const select = screen.getByRole('combobox');
      expect(select).toBeInTheDocument();
      expect(select).toHaveValue('12');
    });

    it('does not render page size selector when onPageSizeChange is not provided', () => {
      render(<Pagination {...defaultProps} />);
      
      expect(screen.queryByText('Show:')).not.toBeInTheDocument();
    });

    it('calls onPageSizeChange when page size is changed', () => {
      const onPageSizeChange = vi.fn();
      render(
        <Pagination 
          {...defaultProps} 
          onPageSizeChange={onPageSizeChange}
        />
      );
      
      const select = screen.getByRole('combobox');
      fireEvent.change(select, { target: { value: '48' } });
      
      expect(onPageSizeChange).toHaveBeenCalledWith(48);
    });

    it('renders custom page size options', () => {
      const onPageSizeChange = vi.fn();
      render(
        <Pagination 
          {...defaultProps} 
          onPageSizeChange={onPageSizeChange}
          pageSizeOptions={[10, 25, 50, 100]}
          itemsPerPage={10}
        />
      );
      const select = screen.getByRole('combobox');
      expect(select).toBeInTheDocument();
      expect(select).toHaveValue('10');
      // Check that all options are rendered
      expect(screen.getByText('10 per page')).toBeInTheDocument();
      expect(screen.getByText('25 per page')).toBeInTheDocument();
      expect(screen.getByText('50 per page')).toBeInTheDocument();
      expect(screen.getByText('100 per page')).toBeInTheDocument();
    });

    it('disables page size selector when loading', () => {
      const onPageSizeChange = vi.fn();
      render(
        <Pagination 
          {...defaultProps} 
          onPageSizeChange={onPageSizeChange}
          loading={true}
        />
      );
      const select = screen.getByRole('combobox');
      expect(select).toBeDisabled();
    });
  });
}); 
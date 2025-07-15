import { render, screen, fireEvent } from '@testing-library/react';
import { describe, it, expect, vi } from 'vitest';
import Pagination from './Pagination';

describe('Pagination', () => {
  const defaultProps = {
    currentPage: 1,
    totalPages: 5,
    onPageChange: vi.fn(),
    hasMore: true,
  };

  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('renders pagination buttons', () => {
    render(<Pagination {...defaultProps} />);

    expect(screen.getByText('Previous')).toBeInTheDocument();
    expect(screen.getByText('Next')).toBeInTheDocument();
    expect(screen.getByText('1')).toBeInTheDocument();
  });

  it('calls onPageChange when clicking page', () => {
    const onPageChange = vi.fn();
    render(<Pagination {...defaultProps} onPageChange={onPageChange} />);

    fireEvent.click(screen.getByText('2'));
    expect(onPageChange).toHaveBeenCalledWith(2);
  });

  it('disables Previous on first page', () => {
    render(<Pagination {...defaultProps} currentPage={1} />);
    expect(screen.getByText('Previous')).toBeDisabled();
  });

  it('disables Next when no more pages', () => {
    render(<Pagination {...defaultProps} hasMore={false} />);
    expect(screen.getByText('Next')).toBeDisabled();
  });
}); 
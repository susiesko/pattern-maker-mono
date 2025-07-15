import React from 'react';
import styled from 'styled-components';

const PaginationContainer = styled.div`
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 8px;
  margin: 24px 0;
  flex-wrap: wrap;
`;

const PaginationControls = styled.div`
  display: flex;
  align-items: center;
  gap: 8px;
`;

const PageSizeContainer = styled.div`
  display: flex;
  align-items: center;
  gap: 8px;
  margin-left: 16px;
`;

const PageSizeLabel = styled.span`
  font-size: 14px;
  color: #6b7280;
`;

const PageSizeSelect = styled.select`
  padding: 6px 8px;
  border: 1px solid #d1d5db;
  border-radius: 4px;
  background: white;
  font-size: 14px;
  color: #374151;
  cursor: pointer;

  &:focus {
    outline: none;
    border-color: #3b82f6;
  }
`;

const PaginationButton = styled.button<{ active?: boolean }>`
  padding: 8px 12px;
  border: 1px solid #d1d5db;
  background: ${props => props.active ? '#3b82f6' : 'white'};
  color: ${props => props.active ? 'white' : '#374151'};
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  transition: all 0.2s;

  &:hover {
    background: ${props => props.active ? '#2563eb' : '#f9fafb'};
  }

  &:disabled {
    background: #f3f4f6;
    color: #9ca3af;
    cursor: not-allowed;
  }
`;

const PaginationInfo = styled.span`
  font-size: 14px;
  color: #6b7280;
  margin: 0 16px;
`;

interface PaginationProps {
  currentPage: number;
  totalPages: number;
  onPageChange: (page: number) => void;
  onPageSizeChange?: (pageSize: number) => void;
  hasMore: boolean;
  loading?: boolean;
  itemsPerPage?: number;
  totalItems?: number;
  pageSizeOptions?: number[];
}

export const Pagination: React.FC<PaginationProps> = ({
  currentPage,
  totalPages,
  onPageChange,
  onPageSizeChange,
  hasMore,
  loading = false,
  itemsPerPage = 12,
  totalItems,
  pageSizeOptions = [12, 24, 48, 96]
}) => {
  const getPageNumbers = () => {
    const pages = [];
    const showPages = 5; // Number of page buttons to show

    if (totalPages <= showPages) {
      // Show all pages if total is small
      for (let i = 1; i <= totalPages; i++) {
        pages.push(i);
      }
    } else {
      // Show current page and surrounding pages
      const start = Math.max(1, currentPage - 2);
      const end = Math.min(totalPages, currentPage + 2);

      // Always show first page
      if (start > 1) {
        pages.push(1);
        if (start > 2) pages.push('...');
      }

      // Show middle pages
      for (let i = start; i <= end; i++) {
        pages.push(i);
      }

      // Always show last page
      if (end < totalPages) {
        if (end < totalPages - 1) pages.push('...');
        pages.push(totalPages);
      }
    }

    return pages;
  };

  const renderPageButton = (page: number | string, index: number) => {
    if (page === '...') {
      return <span key={index}>...</span>;
    }

    return (
      <PaginationButton
        key={index}
        active={page === currentPage}
        onClick={() => onPageChange(page as number)}
        disabled={loading}
      >
        {page}
      </PaginationButton>
    );
  };

  const handlePageSizeChange = (event: React.ChangeEvent<HTMLSelectElement>) => {
    const newPageSize = parseInt(event.target.value);
    if (onPageSizeChange) {
      onPageSizeChange(newPageSize);
    }
  };

  return (
    <PaginationContainer>
      <PaginationControls>
        <PaginationButton
          onClick={() => onPageChange(currentPage - 1)}
          disabled={currentPage === 1 || loading}
        >
          Previous
        </PaginationButton>

        {getPageNumbers().map(renderPageButton)}

        <PaginationButton
          onClick={() => onPageChange(currentPage + 1)}
          disabled={!hasMore || loading}
        >
          Next
        </PaginationButton>
      </PaginationControls>

      {onPageSizeChange && (
        <PageSizeContainer>
          <PageSizeLabel>Show:</PageSizeLabel>
          <PageSizeSelect
            value={itemsPerPage}
            onChange={handlePageSizeChange}
            disabled={loading}
          >
            {pageSizeOptions.map(size => (
              <option key={size} value={size}>
                {size} per page
              </option>
            ))}
          </PageSizeSelect>
        </PageSizeContainer>
      )}

      {totalItems && (
        <PaginationInfo>
          Showing {(currentPage - 1) * itemsPerPage + 1} to{' '}
          {Math.min(currentPage * itemsPerPage, totalItems)} of {totalItems} items
        </PaginationInfo>
      )}
    </PaginationContainer>
  );
};

export default Pagination; 
import React, { useState, useCallback, useMemo } from 'react';
import { useNavigate } from 'react-router-dom';
import styled from 'styled-components';
import { Bead } from '../types/beads';
import { usePaginatedBeadsQuery, BeadFilters as PaginatedBeadFilters } from '../hooks/queries/usePaginatedBeadsQuery';
import { BeadCard, BeadFilters, BeadSearch, BeadSort } from '../components/catalog';
import { LoadingSpinner, ErrorMessage, EmptyState } from '../components/ui';
import Pagination from '../components/Pagination';

interface BeadFilters {
  search: string;
  brandId: string;
  shape: string;
  size: string;
  color_group: string;
  finish: string;
}

interface BeadSort {
  field: 'name' | 'brand' | 'created_at' | 'updated_at';
  direction: 'asc' | 'desc';
}

const BeadsListPage: React.FC = () => {
  const navigate = useNavigate();

  // State management
  const [filters, setFilters] = useState<BeadFilters>({
    search: '',
    brandId: '',
    shape: '',
    size: '',
    color_group: '',
    finish: '',
  });

  const [sort, setSort] = useState<BeadSort>({
    field: 'name',
    direction: 'asc',
  });

  const [currentPage, setCurrentPage] = useState(1);
  const [pageSize, setPageSize] = useState(24);

  // Convert our filters to the format expected by usePaginatedBeadsQuery
  const paginatedFilters = useMemo((): PaginatedBeadFilters => ({
    page: currentPage,
    per_page: pageSize,
    sort_by: sort.field === 'brand' ? 'name' : (sort.field === 'name' ? 'name' : sort.field === 'created_at' ? 'created_at' : 'id'),
    direction: sort.direction,
    search: filters.search || undefined,
    brand_id: filters.brandId ? parseInt(filters.brandId) : undefined,
    shape: filters.shape || undefined,
    size: filters.size || undefined,
    color_group: filters.color_group || undefined,
    finish: filters.finish || undefined,
  }), [filters, sort, pageSize, currentPage]);

  // Data fetching
  const { data, isLoading, error, refetch } = usePaginatedBeadsQuery(paginatedFilters);

  // Event handlers
  const handleFilterChange = useCallback((newFilters: Partial<BeadFilters>) => {
    setFilters(prev => ({ ...prev, ...newFilters }));
    setCurrentPage(1); // Reset to first page when filtering
  }, []);

  const handleSortChange = useCallback((newSort: BeadSort) => {
    setSort(newSort);
    setCurrentPage(1); // Reset to first page when sorting
  }, []);

  const handlePageChange = useCallback((page: number) => {
    setCurrentPage(page);
  }, []);

  const handlePageSizeChange = useCallback((newPageSize: number) => {
    setPageSize(newPageSize);
    setCurrentPage(1); // Reset to first page when changing page size
  }, []);

  const handleAddBead = useCallback(() => {
    navigate('/beads/add');
  }, [navigate]);

  const handleEditBead = useCallback((id: number) => {
    navigate(`/beads/edit/${id}`);
  }, [navigate]);

  const handleViewBead = useCallback((id: number) => {
    navigate(`/beads/${id}`);
  }, [navigate]);

  // Memoized computed values
  const hasFilters = useMemo(() =>
    Object.values(filters).some(value => value !== ''),
    [filters]
  );

  const beadsData = useMemo(() => data?.data || [], [data]);
  const isEmpty = !isLoading && beadsData.length === 0;
  const isFiltered = isEmpty && hasFilters;

  // Loading state
  if (isLoading) {
    return (
      <Container>
        <LoadingSpinner message="Loading beads..." />
      </Container>
    );
  }

  // Error state
  if (error) {
    return (
      <Container>
        <ErrorMessage
          message="Failed to load beads. Please try again."
          onRetry={refetch}
        />
      </Container>
    );
  }

  return (
    <Container>
      <Header>
        <HeaderContent>
          <Title>Bead Catalog</Title>
          <HeaderActions>
            <BeadCount>
              {beadsData.length} {beadsData.length === 1 ? 'bead' : 'beads'}
              {hasFilters && ' (filtered)'}
            </BeadCount>
            <AddButton onClick={handleAddBead}>
              Add New Bead
            </AddButton>
          </HeaderActions>
        </HeaderContent>
      </Header>

      <ToolbarContainer>
        <SearchSection>
          <BeadSearch
            value={filters.search}
            onChange={(search) => handleFilterChange({ search })}
            placeholder="Search beads by name, product code, or brand..."
          />
        </SearchSection>

        <FilterSection>
          <BeadFilters
            filters={filters}
            onChange={handleFilterChange}
          />
        </FilterSection>

        <SortSection>
          <BeadSort
            sort={sort}
            onChange={handleSortChange}
          />
        </SortSection>
      </ToolbarContainer>

      <MainContent>
        {isEmpty ? (
          <EmptyState
            title={isFiltered ? "No beads found" : "No beads yet"}
            message={
              isFiltered
                ? "Try adjusting your filters to find what you're looking for."
                : "Get started by adding your first bead to the catalog."
            }
            actionLabel={isFiltered ? "Clear Filters" : "Add First Bead"}
            onAction={isFiltered ?
              () => handleFilterChange({
                search: '',
                brandId: '',
                shape: '',
                size: '',
                color_group: '',
                finish: '',
              }) :
              handleAddBead
            }
          />
        ) : (
          <>
            <BeadsGrid>
              {beadsData.map((bead: Bead) => (
                <BeadCard
                  key={bead.id}
                  bead={bead}
                  onEdit={handleEditBead}
                  onView={handleViewBead}
                />
              ))}
            </BeadsGrid>

            {data?.pagination && (
              <PaginationContainer>
                <Pagination
                  currentPage={currentPage}
                  totalPages={data.pagination.total_pages}
                  onPageChange={handlePageChange}
                  onPageSizeChange={handlePageSizeChange}
                  hasMore={data.pagination.has_more}
                  loading={isLoading}
                  itemsPerPage={pageSize}
                  totalItems={data.pagination.total_count}
                />
              </PaginationContainer>
            )}
          </>
        )}
      </MainContent>
    </Container>
  );
};

export default BeadsListPage;

// Styled Components
const Container = styled.div`
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  background-color: ${props => props.theme.colors.secondary};
`;

const Header = styled.header`
  background-color: ${props => props.theme.colors.white};
  border-bottom: 1px solid ${props => props.theme.colors.border};
  padding: ${props => props.theme.spacing.lg} 0;
  position: sticky;
  top: 0;
  z-index: 100;
`;

const HeaderContent = styled.div`
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 ${props => props.theme.spacing.lg};
  display: flex;
  justify-content: space-between;
  align-items: center;
`;

const Title = styled.h1`
  color: ${props => props.theme.colors.text};
  font-size: ${props => props.theme.fontSizes.xlarge};
  font-weight: 600;
  margin: 0;
`;

const HeaderActions = styled.div`
  display: flex;
  align-items: center;
  gap: ${props => props.theme.spacing.md};
`;

const BeadCount = styled.span`
  color: ${props => props.theme.colors.lightText};
  font-size: ${props => props.theme.fontSizes.small};
`;

const AddButton = styled.button`
  background-color: ${props => props.theme.colors.primary};
  color: white;
  border: none;
  border-radius: ${props => props.theme.borderRadius.small};
  padding: ${props => props.theme.spacing.sm} ${props => props.theme.spacing.lg};
  font-size: ${props => props.theme.fontSizes.medium};
  font-weight: 500;
  cursor: pointer;
  transition: all ${props => props.theme.transitions.default};

  &:hover {
    background-color: ${props => props.theme.colors.primaryDark};
    transform: translateY(-1px);
  }

  &:active {
    transform: translateY(0);
  }
`;

const ToolbarContainer = styled.div`
  background-color: ${props => props.theme.colors.white};
  border-bottom: 1px solid ${props => props.theme.colors.border};
  padding: ${props => props.theme.spacing.lg} 0;
`;

const SearchSection = styled.div`
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 ${props => props.theme.spacing.lg};
  margin-bottom: ${props => props.theme.spacing.md};
`;

const FilterSection = styled.div`
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 ${props => props.theme.spacing.lg};
  margin-bottom: ${props => props.theme.spacing.md};
`;

const SortSection = styled.div`
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 ${props => props.theme.spacing.lg};
  display: flex;
  justify-content: flex-end;
`;

const MainContent = styled.main`
  flex: 1;
  max-width: 1200px;
  margin: 0 auto;
  padding: ${props => props.theme.spacing.xl} ${props => props.theme.spacing.lg};
  width: 100%;
`;

const BeadsGrid = styled.div`
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: ${props => props.theme.spacing.lg};
  margin-bottom: ${props => props.theme.spacing.xl};
`;

const PaginationContainer = styled.div`
  display: flex;
  justify-content: center;
  margin-top: ${props => props.theme.spacing.xl};
`; 
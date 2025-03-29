import { ChangeEvent, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import styled from 'styled-components';
import useBeadsQuery from '../../hooks/queries/useBeadsQuery.ts';
import { Bead } from '../../types/beads.ts';
import ColorFilterSelect from './filters/ColorFilterSelect.tsx';
import FinishFilterSelect from './filters/FinishFilterSelect.tsx';

const BeadsList = () => {
  const navigate = useNavigate();
  const [filters, setFilters] = useState<Record<string, string>>({});
  const { data, isLoading, error } = useBeadsQuery(filters);

  const handleFilterChange = (e: ChangeEvent<HTMLSelectElement | HTMLInputElement>) => {
    const { name, value } = e.target;
    setFilters(prev => ({
      ...prev,
      [name]: value ?? '',
    }));
  };

  const handleAddBead = () => {
    navigate('/beads/add');
  };

  const handleEditBead = (id: number) => {
    navigate(`/beads/edit/${id}`);
  };

  if (isLoading) return <LoadingMessage>Loading beads...</LoadingMessage>;

  if (error) return <ErrorMessage>Error loading beads. Please try again later.</ErrorMessage>;

  return (
    <Container>
      <HeaderContainer>
        <Title>Bead Catalog</Title>
        <AddButton onClick={handleAddBead}>Add New Bead</AddButton>
      </HeaderContainer>

      <FiltersContainer>
        <FilterGroup>
          <SearchInput
            type="text"
            name="search"
            placeholder="Search beads..."
            onChange={handleFilterChange}
          />
        </FilterGroup>
        {/* We could add more filters here based on the API's capabilities */}
        <FilterGroup>
          <ColorFilterSelect onChange={handleFilterChange} value={filters.color || ''} />
        </FilterGroup>
        <FilterGroup>
          <FinishFilterSelect onChange={handleFilterChange} value={filters.finish || ''} />
        </FilterGroup>
      </FiltersContainer>

      <BeadsGrid>
        {data?.map((bead: Bead) => (
          <BeadCard key={bead.id}>
            <BeadImage>
              {bead.image ? (
                <BeadImg src={`/bead-images/${bead.image}`} alt={bead.name} />
              ) : (
                <PlaceholderImage />
              )}
            </BeadImage>
            <BeadInfo>
              <BeadName>{bead.name}</BeadName>
              <ProductCode>{bead.brand_product_code}</ProductCode>
              <BrandName>{bead.brand.name}</BrandName>
              <TypeSize>
                {bead.type.name} - {bead.size.size}
              </TypeSize>
              <TagsContainer>
                {bead.colors.map(color => (
                  <ColorTag key={color.id}>{color.name}</ColorTag>
                ))}
              </TagsContainer>
              <TagsContainer>
                {bead.finishes.map(finish => (
                  <FinishTag key={finish.id}>{finish.name}</FinishTag>
                ))}
              </TagsContainer>
              <CardActions>
                <EditButton onClick={() => handleEditBead(bead.id)}>Edit</EditButton>
              </CardActions>
            </BeadInfo>
          </BeadCard>
        ))}
      </BeadsGrid>
    </Container>
  );
};

export default BeadsList;

// Styled components
const Container = styled.div`
  width: 100%;
  height: 100%;
  display: flex;
  flex-direction: column;
`;

const HeaderContainer = styled.div`
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: ${props => props.theme.spacing.xl} ${props => props.theme.spacing.xl} 0;
  margin-bottom: ${props => props.theme.spacing.xl};
`;

const Title = styled.h1`
  color: ${props => props.theme.colors.text};
  margin: 0;
`;

const AddButton = styled.button`
  background-color: ${props => props.theme.colors.primary};
  color: white;
  border: none;
  border-radius: ${props => props.theme.borderRadius.small};
  padding: ${props => props.theme.spacing.md} ${props => props.theme.spacing.lg};
  font-size: ${props => props.theme.fontSizes.medium};
  cursor: pointer;
  transition: background-color ${props => props.theme.transitions.default};

  &:hover {
    background-color: ${props => props.theme.colors.primaryDark};
  }
`;

const FiltersContainer = styled.div`
  margin-bottom: ${props => props.theme.spacing.xl};
  display: flex;
  justify-content: flex-start;
  flex-wrap: wrap;
  gap: ${props => props.theme.spacing.md};
  width: 100%;
  padding: 0 ${props => props.theme.spacing.xl};
`;

const FilterGroup = styled.div`
  display: flex;
  flex-direction: column;
  min-width: 200px;
`;

const SearchInput = styled.input`
  padding: 0.75rem;
  border: 1px solid ${props => props.theme.colors.border};
  border-radius: ${props => props.theme.borderRadius.small};
  font-size: ${props => props.theme.fontSizes.medium};
  width: 100%;
  transition: border-color ${props => props.theme.transitions.default};

  &:focus {
    border-color: ${props => props.theme.colors.primary};
    outline: none;
  }
`;

const BeadsGrid = styled.div`
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
  gap: ${props => props.theme.spacing.xl};
  margin-bottom: ${props => props.theme.spacing.xl};
  width: 100%;
  padding: 0 ${props => props.theme.spacing.xl};
`;

const BeadCard = styled.div`
  border-radius: ${props => props.theme.borderRadius.medium};
  overflow: hidden;
  box-shadow: ${props => props.theme.shadows.medium};
  transition:
    transform ${props => props.theme.transitions.default},
    box-shadow ${props => props.theme.transitions.default};
  background-color: ${props => props.theme.colors.white};

  &:hover {
    transform: translateY(-5px);
    box-shadow: ${props => props.theme.shadows.large};
  }
`;

const BeadImage = styled.div`
  height: 180px;
  background-color: ${props => props.theme.colors.secondary};
  display: flex;
  align-items: center;
  justify-content: center;
`;

const BeadImg = styled.img`
  max-width: 100%;
  max-height: 100%;
  object-fit: contain;
`;

const PlaceholderImage = styled.div`
  width: 80px;
  height: 80px;
  border-radius: ${props => props.theme.borderRadius.round};
  background-color: #e0e0e0;
`;

const BeadInfo = styled.div`
  padding: ${props => props.theme.spacing.lg};
`;

const BeadName = styled.h3`
  margin: 0 0 ${props => props.theme.spacing.sm} 0;
  font-size: ${props => props.theme.fontSizes.large};
  color: ${props => props.theme.colors.text};
`;

const ProductCode = styled.p`
  color: ${props => props.theme.colors.lightText};
  font-size: 0.9rem;
  margin: 0 0 ${props => props.theme.spacing.sm} 0;
`;

const BrandName = styled.p`
  font-weight: bold;
  margin: 0 0 ${props => props.theme.spacing.sm} 0;
`;

const TypeSize = styled.p`
  color: ${props => props.theme.colors.lightText};
  margin: 0 0 ${props => props.theme.spacing.md} 0;
`;

const TagsContainer = styled.div`
  display: flex;
  flex-wrap: wrap;
  gap: ${props => props.theme.spacing.sm};
  margin-top: ${props => props.theme.spacing.sm};
`;

const ColorTag = styled.span`
  padding: ${props => props.theme.spacing.xs} ${props => props.theme.spacing.sm};
  border-radius: ${props => props.theme.borderRadius.small};
  font-size: ${props => props.theme.fontSizes.small};
  background-color: ${props => props.theme.colors.colorTag.bg};
  color: ${props => props.theme.colors.colorTag.text};
`;

const FinishTag = styled.span`
  padding: ${props => props.theme.spacing.xs} ${props => props.theme.spacing.sm};
  border-radius: ${props => props.theme.borderRadius.small};
  font-size: ${props => props.theme.fontSizes.small};
  background-color: ${props => props.theme.colors.finishTag.bg};
  color: ${props => props.theme.colors.finishTag.text};
`;

const CardActions = styled.div`
  display: flex;
  justify-content: flex-end;
  margin-top: ${props => props.theme.spacing.md};
`;

const EditButton = styled.button`
  background-color: transparent;
  color: ${props => props.theme.colors.primary};
  border: 1px solid ${props => props.theme.colors.primary};
  border-radius: ${props => props.theme.borderRadius.small};
  padding: ${props => props.theme.spacing.xs} ${props => props.theme.spacing.md};
  font-size: ${props => props.theme.fontSizes.small};
  cursor: pointer;
  transition: all ${props => props.theme.transitions.default};

  &:hover {
    background-color: ${props => props.theme.colors.primaryLight};
  }
`;

const LoadingMessage = styled.div`
  text-align: center;
  padding: ${props => props.theme.spacing.xl};
  font-size: ${props => props.theme.fontSizes.large};
  color: ${props => props.theme.colors.primary};
  width: 100%;
  height: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
`;

const ErrorMessage = styled.div`
  text-align: center;
  padding: ${props => props.theme.spacing.xl};
  font-size: ${props => props.theme.fontSizes.large};
  color: ${props => props.theme.colors.error};
  width: 100%;
  height: 100%;
  display: flex;
  justify-content: center;
  align-items: center;
`;

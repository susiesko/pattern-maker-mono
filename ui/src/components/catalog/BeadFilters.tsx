import React from 'react';
import styled from 'styled-components';
import { useBeadBrandsQuery, useBeadTypesQuery, useBeadSizesQuery, useBeadColorsQuery, useBeadFinishesQuery } from '../../hooks/queries';

interface BeadFiltersProps {
  filters: {
    brandId: string;
    shape: string;
    size: string;
    color_group: string;
    finish: string;
  };
  onChange: (filters: Partial<BeadFiltersProps['filters']>) => void;
}

const BeadFilters: React.FC<BeadFiltersProps> = ({ filters, onChange }) => {
  const { data: brands } = useBeadBrandsQuery();
  const { data: shapes } = useBeadTypesQuery(); // Types query now returns shapes
  const { data: sizes } = useBeadSizesQuery();
  const { data: colors } = useBeadColorsQuery();
  const { data: finishes } = useBeadFinishesQuery();

  const handleFilterChange = (key: keyof BeadFiltersProps['filters'], value: string) => {
    onChange({ [key]: value });
  };

  const handleClearFilters = () => {
    onChange({
      brandId: '',
      shape: '',
      size: '',
      color_group: '',
      finish: '',
    });
  };

  const hasActiveFilters = Object.values(filters).some(value => value !== '');

  return (
    <FiltersContainer>
      <FiltersGrid>
        <FilterGroup>
          <FilterLabel htmlFor="brand-filter">Brand</FilterLabel>
          <FilterSelect
            id="brand-filter"
            value={filters.brandId}
            onChange={(e) => handleFilterChange('brandId', e.target.value)}
          >
            <option value="">All Brands</option>
            {brands?.map(brand => (
              <option key={brand.id} value={brand.id}>
                {brand.name}
              </option>
            ))}
          </FilterSelect>
        </FilterGroup>

        <FilterGroup>
          <FilterLabel htmlFor="shape-filter">Shape</FilterLabel>
          <FilterSelect
            id="shape-filter"
            value={filters.shape}
            onChange={(e) => handleFilterChange('shape', e.target.value)}
          >
            <option value="">All Shapes</option>
            {shapes?.map(shape => (
              <option key={shape} value={shape}>
                {shape}
              </option>
            ))}
          </FilterSelect>
        </FilterGroup>

        <FilterGroup>
          <FilterLabel htmlFor="size-filter">Size</FilterLabel>
          <FilterSelect
            id="size-filter"
            value={filters.size}
            onChange={(e) => handleFilterChange('size', e.target.value)}
          >
            <option value="">All Sizes</option>
            {sizes?.map(size => (
              <option key={size} value={size}>
                {size}
              </option>
            ))}
          </FilterSelect>
        </FilterGroup>

        <FilterGroup>
          <FilterLabel htmlFor="color-filter">Color</FilterLabel>
          <FilterSelect
            id="color-filter"
            value={filters.color_group}
            onChange={(e) => handleFilterChange('color_group', e.target.value)}
          >
            <option value="">All Colors</option>
            {colors?.map(color => (
              <option key={color} value={color}>
                {color}
              </option>
            ))}
          </FilterSelect>
        </FilterGroup>

        <FilterGroup>
          <FilterLabel htmlFor="finish-filter">Finish</FilterLabel>
          <FilterSelect
            id="finish-filter"
            value={filters.finish}
            onChange={(e) => handleFilterChange('finish', e.target.value)}
          >
            <option value="">All Finishes</option>
            {finishes?.map(finish => (
              <option key={finish} value={finish}>
                {finish}
              </option>
            ))}
          </FilterSelect>
        </FilterGroup>
      </FiltersGrid>

      {hasActiveFilters && (
        <ClearFiltersButton type="button" onClick={handleClearFilters}>
          Clear All Filters
        </ClearFiltersButton>
      )}
    </FiltersContainer>
  );
};

export default BeadFilters;

// Styled Components
const FiltersContainer = styled.div`
  display: flex;
  flex-direction: column;
  gap: ${props => props.theme.spacing.md};
`;

const FiltersGrid = styled.div`
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
  gap: ${props => props.theme.spacing.md};
`;

const FilterGroup = styled.div`
  display: flex;
  flex-direction: column;
  gap: ${props => props.theme.spacing.xs};
`;

const FilterLabel = styled.label`
  font-size: ${props => props.theme.fontSizes.small};
  font-weight: 600;
  color: ${props => props.theme.colors.text};
`;

const FilterSelect = styled.select`
  padding: ${props => props.theme.spacing.sm};
  border: 1px solid ${props => props.theme.colors.border};
  border-radius: ${props => props.theme.borderRadius.small};
  font-size: ${props => props.theme.fontSizes.medium};
  background-color: ${props => props.theme.colors.white};
  cursor: pointer;
  transition: border-color ${props => props.theme.transitions.default};

  &:focus {
    outline: none;
    border-color: ${props => props.theme.colors.primary};
  }

  &:hover {
    border-color: ${props => props.theme.colors.primary};
  }
`;

const ClearFiltersButton = styled.button`
  background: none;
  border: none;
  color: ${props => props.theme.colors.primary};
  font-size: ${props => props.theme.fontSizes.small};
  cursor: pointer;
  padding: ${props => props.theme.spacing.xs};
  align-self: flex-start;
  transition: color ${props => props.theme.transitions.default};

  &:hover {
    color: ${props => props.theme.colors.primaryDark};
    text-decoration: underline;
  }
`; 
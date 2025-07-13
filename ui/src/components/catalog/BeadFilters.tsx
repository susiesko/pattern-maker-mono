import React from 'react';
import styled from 'styled-components';
import { useBeadBrandsQuery, useBeadTypesQuery, useBeadSizesQuery, useBeadColorsQuery, useBeadFinishesQuery } from '../../hooks/queries';

interface BeadFiltersProps {
  filters: {
    brandId: string;
    typeId: string;
    sizeId: string;
    colorId: string;
    finishId: string;
  };
  onChange: (filters: Partial<BeadFiltersProps['filters']>) => void;
}

const BeadFilters: React.FC<BeadFiltersProps> = ({ filters, onChange }) => {
  const { data: brands } = useBeadBrandsQuery();
  const { data: types } = useBeadTypesQuery();
  const { data: sizes } = useBeadSizesQuery();
  const { data: colors } = useBeadColorsQuery();
  const { data: finishes } = useBeadFinishesQuery();

  const handleFilterChange = (key: keyof BeadFiltersProps['filters'], value: string) => {
    onChange({ [key]: value });
  };

  const handleClearFilters = () => {
    onChange({
      brandId: '',
      typeId: '',
      sizeId: '',
      colorId: '',
      finishId: '',
    });
  };

  const hasActiveFilters = Object.values(filters).some(value => value !== '');

  return (
    <FiltersContainer>
      <FiltersGrid>
        <FilterGroup>
          <FilterLabel>Brand</FilterLabel>
          <FilterSelect
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
          <FilterLabel>Type</FilterLabel>
          <FilterSelect
            value={filters.typeId}
            onChange={(e) => handleFilterChange('typeId', e.target.value)}
          >
            <option value="">All Types</option>
            {types?.map(type => (
              <option key={type.id} value={type.id}>
                {type.name}
              </option>
            ))}
          </FilterSelect>
        </FilterGroup>

        <FilterGroup>
          <FilterLabel>Size</FilterLabel>
          <FilterSelect
            value={filters.sizeId}
            onChange={(e) => handleFilterChange('sizeId', e.target.value)}
          >
            <option value="">All Sizes</option>
            {sizes?.map(size => (
              <option key={size.id} value={size.id}>
                {size.size}
              </option>
            ))}
          </FilterSelect>
        </FilterGroup>

        <FilterGroup>
          <FilterLabel>Color</FilterLabel>
          <FilterSelect
            value={filters.colorId}
            onChange={(e) => handleFilterChange('colorId', e.target.value)}
          >
            <option value="">All Colors</option>
            {colors?.map(color => (
              <option key={color.id} value={color.id}>
                {color.name}
              </option>
            ))}
          </FilterSelect>
        </FilterGroup>

        <FilterGroup>
          <FilterLabel>Finish</FilterLabel>
          <FilterSelect
            value={filters.finishId}
            onChange={(e) => handleFilterChange('finishId', e.target.value)}
          >
            <option value="">All Finishes</option>
            {finishes?.map(finish => (
              <option key={finish.id} value={finish.id}>
                {finish.name}
              </option>
            ))}
          </FilterSelect>
        </FilterGroup>
      </FiltersGrid>

      {hasActiveFilters && (
        <ClearFiltersButton onClick={handleClearFilters}>
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
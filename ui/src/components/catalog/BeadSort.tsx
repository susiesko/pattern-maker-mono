import React from 'react';
import styled from 'styled-components';

interface BeadSortProps {
  sort: {
    field: 'name' | 'brand' | 'created_at' | 'updated_at';
    direction: 'asc' | 'desc';
  };
  onChange: (sort: BeadSortProps['sort']) => void;
}

const BeadSort: React.FC<BeadSortProps> = ({ sort, onChange }) => {
  const handleSortFieldChange = (field: BeadSortProps['sort']['field']) => {
    onChange({ field, direction: sort.direction });
  };

  const handleSortDirectionChange = (direction: BeadSortProps['sort']['direction']) => {
    onChange({ field: sort.field, direction });
  };

  const sortOptions = [
    { value: 'name', label: 'Name' },
    { value: 'brand', label: 'Brand' },
    { value: 'created_at', label: 'Date Added' },
    { value: 'updated_at', label: 'Last Updated' },
  ] as const;

  return (
    <SortContainer>
      <SortGroup>
        <SortLabel>Sort by:</SortLabel>
        <SortSelect
          value={sort.field}
          onChange={(e) => handleSortFieldChange(e.target.value as BeadSortProps['sort']['field'])}
        >
          {sortOptions.map(option => (
            <option key={option.value} value={option.value}>
              {option.label}
            </option>
          ))}
        </SortSelect>
      </SortGroup>

      <SortGroup>
        <SortDirectionButton
          type="button"
          $isActive={sort.direction === 'asc'}
          onClick={() => handleSortDirectionChange('asc')}
          title="Sort ascending"
        >
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path
              d="M12 5L19 12L17.59 13.41L13 8.83V19H11V8.83L6.41 13.41L5 12L12 5Z"
              fill="currentColor"
            />
          </svg>
        </SortDirectionButton>

        <SortDirectionButton
          type="button"
          $isActive={sort.direction === 'desc'}
          onClick={() => handleSortDirectionChange('desc')}
          title="Sort descending"
        >
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path
              d="M12 19L5 12L6.41 10.59L11 15.17V5H13V15.17L17.59 10.59L19 12L12 19Z"
              fill="currentColor"
            />
          </svg>
        </SortDirectionButton>
      </SortGroup>
    </SortContainer>
  );
};

export default BeadSort;

// Styled Components
const SortContainer = styled.div`
  display: flex;
  align-items: center;
  gap: ${props => props.theme.spacing.md};
`;

const SortGroup = styled.div`
  display: flex;
  align-items: center;
  gap: ${props => props.theme.spacing.sm};
`;

const SortLabel = styled.label`
  font-size: ${props => props.theme.fontSizes.small};
  font-weight: 600;
  color: ${props => props.theme.colors.text};
`;

const SortSelect = styled.select`
  padding: ${props => props.theme.spacing.sm};
  border: 1px solid ${props => props.theme.colors.border};
  border-radius: ${props => props.theme.borderRadius.small};
  font-size: ${props => props.theme.fontSizes.small};
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

const SortDirectionButton = styled.button<{ $isActive: boolean }>`
  background-color: ${props => props.$isActive ? props.theme.colors.primary : 'transparent'};
  color: ${props => props.$isActive ? 'white' : props.theme.colors.lightText};
  border: 1px solid ${props => props.$isActive ? props.theme.colors.primary : props.theme.colors.border};
  border-radius: ${props => props.theme.borderRadius.small};
  padding: ${props => props.theme.spacing.xs};
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all ${props => props.theme.transitions.default};

  &:hover {
    background-color: ${props => props.$isActive ? props.theme.colors.primaryDark : props.theme.colors.secondary};
    color: ${props => props.$isActive ? 'white' : props.theme.colors.text};
  }
`; 
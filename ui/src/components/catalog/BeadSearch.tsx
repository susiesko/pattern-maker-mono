import React, { useState, useEffect, useRef } from 'react';
import styled from 'styled-components';

interface BeadSearchProps {
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
  debounceMs?: number;
}

const BeadSearch: React.FC<BeadSearchProps> = ({
  value,
  onChange,
  placeholder = 'Search beads...',
  debounceMs = 300
}) => {
  const [inputValue, setInputValue] = useState(value);
  const debounceRef = useRef<number>();

  useEffect(() => {
    setInputValue(value);
  }, [value]);

  useEffect(() => {
    if (debounceRef.current) {
      clearTimeout(debounceRef.current);
    }

    debounceRef.current = window.setTimeout(() => {
      onChange(inputValue);
    }, debounceMs);

    return () => {
      if (debounceRef.current) {
        clearTimeout(debounceRef.current);
      }
    };
  }, [inputValue, onChange, debounceMs]);

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setInputValue(e.target.value);
  };

  const handleClear = () => {
    setInputValue('');
  };

  return (
    <SearchContainer>
      <SearchInputContainer>
        <SearchIcon>
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path
              d="M21 21L16.514 16.506L21 21ZM19 10.5C19 15.194 15.194 19 10.5 19C5.806 19 2 15.194 2 10.5C2 5.806 5.806 2 10.5 2C15.194 2 19 5.806 19 10.5Z"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
          </svg>
        </SearchIcon>

        <SearchInput
          type="text"
          value={inputValue}
          onChange={handleInputChange}
          placeholder={placeholder}
        />

        {inputValue && (
          <ClearButton onClick={handleClear} type="button">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path
                d="M18 6L6 18M6 6L18 18"
                stroke="currentColor"
                strokeWidth="2"
                strokeLinecap="round"
                strokeLinejoin="round"
              />
            </svg>
          </ClearButton>
        )}
      </SearchInputContainer>
    </SearchContainer>
  );
};

export default BeadSearch;

// Styled Components
const SearchContainer = styled.div`
  width: 100%;
  max-width: 500px;
`;

const SearchInputContainer = styled.div`
  position: relative;
  display: flex;
  align-items: center;
`;

const SearchIcon = styled.div`
  position: absolute;
  left: ${props => props.theme.spacing.md};
  color: ${props => props.theme.colors.lightText};
  z-index: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  pointer-events: none;
`;

const SearchInput = styled.input`
  width: 100%;
  padding: ${props => props.theme.spacing.md};
  padding-left: calc(${props => props.theme.spacing.md} + 20px + ${props => props.theme.spacing.sm});
  padding-right: calc(${props => props.theme.spacing.md} + 20px + ${props => props.theme.spacing.sm});
  border: 1px solid ${props => props.theme.colors.border};
  border-radius: ${props => props.theme.borderRadius.medium};
  font-size: ${props => props.theme.fontSizes.medium};
  background-color: ${props => props.theme.colors.white};
  transition: all ${props => props.theme.transitions.default};
  
  &:focus {
    outline: none;
    border-color: ${props => props.theme.colors.primary};
    box-shadow: 0 0 0 2px ${props => props.theme.colors.primary}20;
  }
  
  &::placeholder {
    color: ${props => props.theme.colors.lightText};
  }
`;

const ClearButton = styled.button`
  position: absolute;
  right: ${props => props.theme.spacing.md};
  background: none;
  border: none;
  color: ${props => props.theme.colors.lightText};
  cursor: pointer;
  padding: ${props => props.theme.spacing.xs};
  display: flex;
  align-items: center;
  justify-content: center;
  transition: color ${props => props.theme.transitions.default};
  
  &:hover {
    color: ${props => props.theme.colors.text};
  }
`; 
import styled from 'styled-components';

export const StyledSelect = styled.select`
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

  &:disabled {
    background-color: ${props => props.theme.colors.disabled};
    cursor: not-allowed;
  }
`;
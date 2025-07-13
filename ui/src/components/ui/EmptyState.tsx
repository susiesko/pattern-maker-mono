import React from 'react';
import styled from 'styled-components';

interface EmptyStateProps {
  title: string;
  message: string;
  actionLabel?: string;
  onAction?: () => void;
  icon?: React.ReactNode;
}

const EmptyState: React.FC<EmptyStateProps> = ({
  title,
  message,
  actionLabel,
  onAction,
  icon
}) => {
  const defaultIcon = (
    <svg width="64" height="64" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path
        d="M9 11H15M9 15H15M17 21H7C5.89543 21 5 20.1046 5 19V5C5 3.89543 5.89543 3 7 3H12.5858C12.851 3 13.1054 3.10536 13.2929 3.29289L18.7071 8.70711C18.8946 8.89464 19 9.149 19 9.41421V19C19 20.1046 18.1046 21 17 21Z"
        stroke="currentColor"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );

  return (
    <Container>
      <IconContainer>
        {icon || defaultIcon}
      </IconContainer>

      <Title>{title}</Title>
      <Message>{message}</Message>

      {actionLabel && onAction && (
        <ActionButton onClick={onAction} type="button">
          {actionLabel}
        </ActionButton>
      )}
    </Container>
  );
};

export default EmptyState;

// Styled Components
const Container = styled.div`
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: ${props => props.theme.spacing.md};
  padding: ${props => props.theme.spacing.xl};
  min-height: 300px;
  text-align: center;
`;

const IconContainer = styled.div`
  color: ${props => props.theme.colors.lightText};
  opacity: 0.6;
`;

const Title = styled.h3`
  color: ${props => props.theme.colors.text};
  font-size: ${props => props.theme.fontSizes.large};
  font-weight: 600;
  margin: 0;
`;

const Message = styled.p`
  color: ${props => props.theme.colors.lightText};
  font-size: ${props => props.theme.fontSizes.medium};
  margin: 0;
  max-width: 400px;
  line-height: 1.5;
`;

const ActionButton = styled.button`
  background-color: ${props => props.theme.colors.primary};
  color: white;
  border: none;
  border-radius: ${props => props.theme.borderRadius.small};
  padding: ${props => props.theme.spacing.sm} ${props => props.theme.spacing.lg};
  font-size: ${props => props.theme.fontSizes.medium};
  font-weight: 500;
  cursor: pointer;
  transition: all ${props => props.theme.transitions.default};
  margin-top: ${props => props.theme.spacing.md};
  
  &:hover {
    background-color: ${props => props.theme.colors.primaryDark};
    transform: translateY(-1px);
  }
  
  &:active {
    transform: translateY(0);
  }
`; 
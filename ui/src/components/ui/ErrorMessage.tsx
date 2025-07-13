import React from 'react';
import styled from 'styled-components';

interface ErrorMessageProps {
  message: string;
  onRetry?: () => void;
  retryLabel?: string;
}

const ErrorMessage: React.FC<ErrorMessageProps> = ({
  message,
  onRetry,
  retryLabel = 'Try Again'
}) => {
  return (
    <Container>
      <ErrorIcon>
        <svg width="48" height="48" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
          <path
            d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"
            fill="currentColor"
          />
          <path
            d="M12 7v6M12 17h.01"
            stroke="currentColor"
            strokeWidth="2"
            strokeLinecap="round"
            strokeLinejoin="round"
          />
        </svg>
      </ErrorIcon>

      <Message>{message}</Message>

      {onRetry && (
        <RetryButton onClick={onRetry} type="button">
          {retryLabel}
        </RetryButton>
      )}
    </Container>
  );
};

export default ErrorMessage;

// Styled Components
const Container = styled.div`
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: ${props => props.theme.spacing.md};
  padding: ${props => props.theme.spacing.xl};
  min-height: 200px;
  text-align: center;
`;

const ErrorIcon = styled.div`
  color: ${props => props.theme.colors.error};
  opacity: 0.8;
`;

const Message = styled.p`
  color: ${props => props.theme.colors.error};
  font-size: ${props => props.theme.fontSizes.medium};
  margin: 0;
  max-width: 400px;
  line-height: 1.5;
`;

const RetryButton = styled.button`
  background-color: ${props => props.theme.colors.error};
  color: white;
  border: none;
  border-radius: ${props => props.theme.borderRadius.small};
  padding: ${props => props.theme.spacing.sm} ${props => props.theme.spacing.lg};
  font-size: ${props => props.theme.fontSizes.medium};
  font-weight: 500;
  cursor: pointer;
  transition: all ${props => props.theme.transitions.default};
  
  &:hover {
    background-color: ${props => props.theme.colors.error}dd;
    transform: translateY(-1px);
  }
  
  &:active {
    transform: translateY(0);
  }
`; 
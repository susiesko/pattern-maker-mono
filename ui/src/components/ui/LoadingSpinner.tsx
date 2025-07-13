import React from 'react';
import styled, { keyframes } from 'styled-components';

interface LoadingSpinnerProps {
  message?: string;
  size?: 'small' | 'medium' | 'large';
}

const LoadingSpinner: React.FC<LoadingSpinnerProps> = ({
  message = 'Loading...',
  size = 'medium'
}) => {
  return (
    <Container>
      <Spinner $size={size} />
      {message && <Message>{message}</Message>}
    </Container>
  );
};

export default LoadingSpinner;

// Keyframes for spinner animation
const spin = keyframes`
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
`;

// Styled Components
const Container = styled.div`
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: ${props => props.theme.spacing.md};
  padding: ${props => props.theme.spacing.xl};
  min-height: 200px;
`;

const Spinner = styled.div<{ $size: 'small' | 'medium' | 'large' }>`
  width: ${props => {
    switch (props.$size) {
      case 'small': return '24px';
      case 'medium': return '40px';
      case 'large': return '60px';
      default: return '40px';
    }
  }};
  height: ${props => {
    switch (props.$size) {
      case 'small': return '24px';
      case 'medium': return '40px';
      case 'large': return '60px';
      default: return '40px';
    }
  }};
  border: 3px solid ${props => props.theme.colors.secondary};
  border-top: 3px solid ${props => props.theme.colors.primary};
  border-radius: 50%;
  animation: ${spin} 1s linear infinite;
`;

const Message = styled.p`
  color: ${props => props.theme.colors.lightText};
  font-size: ${props => props.theme.fontSizes.medium};
  margin: 0;
  text-align: center;
`; 
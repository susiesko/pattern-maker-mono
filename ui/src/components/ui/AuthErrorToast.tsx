import React, { useEffect, useState } from 'react';
import styled from 'styled-components';
import { useAuth } from '../../context/AuthContext';

const ToastContainer = styled.div<{ isVisible: boolean }>`
  position: fixed;
  top: 20px;
  right: 20px;
  background-color: #ef4444;
  color: white;
  padding: 16px 20px;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  z-index: 1000;
  max-width: 400px;
  transform: translateX(${props => props.isVisible ? '0' : '100%'});
  transition: transform 0.3s ease-in-out;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
`;

const Message = styled.div`
  flex: 1;
  font-size: 14px;
  line-height: 1.4;
`;

const CloseButton = styled.button`
  background: none;
  border: none;
  color: white;
  cursor: pointer;
  padding: 4px;
  font-size: 18px;
  line-height: 1;
  opacity: 0.8;
  transition: opacity 0.2s;

  &:hover {
    opacity: 1;
  }
`;

const AuthErrorToast: React.FC = () => {
  const { error, clearError } = useAuth();
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    if (error) {
      setIsVisible(true);
      
      // Auto-hide after 5 seconds for non-expiration errors
      const isExpirationError = error.includes('expired') || error.includes('session');
      const timeout = isExpirationError ? 10000 : 5000; // 10 seconds for expiration, 5 for others
      
      const timer = setTimeout(() => {
        setIsVisible(false);
        setTimeout(() => clearError(), 300); // Clear error after animation
      }, timeout);

      return () => clearTimeout(timer);
    } else {
      setIsVisible(false);
    }
  }, [error, clearError]);

  const handleClose = () => {
    setIsVisible(false);
    setTimeout(() => clearError(), 300);
  };

  if (!error) return null;

  return (
    <ToastContainer isVisible={isVisible}>
      <Message>{error}</Message>
      <CloseButton onClick={handleClose} aria-label="Close notification">
        ×
      </CloseButton>
    </ToastContainer>
  );
};

export default AuthErrorToast; 
import React, { useState } from 'react';
import styled from 'styled-components';
import { useAuth } from '../../context/AuthContext';
import { 
  setupExpiredTokenForTesting, 
  clearTestTokens, 
  createSoonToExpireToken 
} from '../../utils/testUtils';

const Container = styled.div`
  max-width: 800px;
  margin: 0 auto;
  padding: 20px;
  font-family: Arial, sans-serif;
`;

const Section = styled.div`
  margin-bottom: 30px;
  padding: 20px;
  border: 1px solid #ddd;
  border-radius: 8px;
  background-color: #f9f9f9;
`;

const Button = styled.button<{ variant?: 'primary' | 'danger' | 'warning' }>`
  padding: 10px 20px;
  margin: 5px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  
  ${props => {
    switch (props.variant) {
      case 'danger':
        return 'background-color: #dc3545; color: white;';
      case 'warning':
        return 'background-color: #ffc107; color: black;';
      default:
        return 'background-color: #007bff; color: white;';
    }
  }}
  
  &:hover {
    opacity: 0.8;
  }
`;

const Status = styled.div<{ type: 'success' | 'error' | 'info' }>`
  padding: 10px;
  margin: 10px 0;
  border-radius: 4px;
  font-weight: bold;
  
  ${props => {
    switch (props.type) {
      case 'success':
        return 'background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb;';
      case 'error':
        return 'background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb;';
      case 'info':
        return 'background-color: #d1ecf1; color: #0c5460; border: 1px solid #bee5eb;';
    }
  }}
`;

const TokenExpirationTestPage: React.FC = () => {
  const { user, isAuthenticated, error, clearError } = useAuth();
  const [testStatus, setTestStatus] = useState<string>('');

  const handleSetupExpiredToken = () => {
    setupExpiredTokenForTesting();
    setTestStatus('✅ Expired token set! Refresh the page to see the expiration handling.');
  };

  const handleSetupSoonToExpireToken = () => {
    const soonToExpireToken = createSoonToExpireToken(10); // 10 seconds
    localStorage.setItem('auth_token', soonToExpireToken);
    localStorage.setItem('user_data', JSON.stringify({
      id: '1',
      email: 'test@example.com',
      name: 'Test User'
    }));
    setTestStatus('⏰ Token set to expire in 10 seconds! Wait and try making an API call.');
  };

  const handleClearTokens = () => {
    clearTestTokens();
    setTestStatus('🧹 Test tokens cleared!');
  };

  const handleTestApiCall = async () => {
    try {
      setTestStatus('🔄 Making API call...');
      const response = await fetch('/api/v1/auth/me', {
        headers: {
          'Authorization': `Bearer ${localStorage.getItem('auth_token')}`,
          'Content-Type': 'application/json'
        }
      });
      
      if (response.status === 401) {
        setTestStatus('❌ API call failed with 401 - token expiration detected!');
      } else {
        setTestStatus('✅ API call successful - token is still valid.');
      }
    } catch (error) {
      setTestStatus(`❌ API call failed: ${error}`);
    }
  };

  const handleClearError = () => {
    clearError();
    setTestStatus('🧹 Error cleared!');
  };

  return (
    <Container>
      <h1>🔧 Token Expiration Test Page</h1>
      
      <Section>
        <h2>Current Auth Status</h2>
        <p><strong>User:</strong> {user?.name || 'Not logged in'}</p>
        <p><strong>Authenticated:</strong> {isAuthenticated ? 'Yes' : 'No'}</p>
        <p><strong>Error:</strong> {error || 'None'}</p>
        {error && (
          <Button onClick={handleClearError} variant="warning">
            Clear Error
          </Button>
        )}
      </Section>

      <Section>
        <h2>🧪 Test Token Expiration</h2>
        <p>Use these buttons to test different token expiration scenarios:</p>
        
        <div>
          <Button onClick={handleSetupExpiredToken} variant="danger">
            Set Expired Token
          </Button>
          <Button onClick={handleSetupSoonToExpireToken} variant="warning">
            Set Token (Expires in 10s)
          </Button>
          <Button onClick={handleClearTokens}>
            Clear Test Tokens
          </Button>
        </div>
        
        <div>
          <Button onClick={handleTestApiCall}>
            Test API Call
          </Button>
        </div>
      </Section>

      {testStatus && (
        <Status type={testStatus.includes('❌') ? 'error' : testStatus.includes('✅') ? 'success' : 'info'}>
          {testStatus}
        </Status>
      )}

      <Section>
        <h2>📋 How to Test</h2>
        <ol>
          <li><strong>Set Expired Token:</strong> Click this button, then refresh the page. You should see the token expiration handling in action.</li>
          <li><strong>Set Soon-to-Expire Token:</strong> Click this button, wait 10 seconds, then try making an API call. The token should expire and trigger the expiration handling.</li>
          <li><strong>Test API Call:</strong> This will make a real API call to test if your token is valid.</li>
          <li><strong>Clear Tokens:</strong> Removes test tokens from localStorage.</li>
        </ol>
      </Section>

      <Section>
        <h2>🔍 What to Look For</h2>
        <ul>
          <li>Red error toast notification when token expires</li>
          <li>Automatic redirect to login page</li>
          <li>User state being cleared</li>
          <li>Console logs showing token expiration handling</li>
        </ul>
      </Section>
    </Container>
  );
};

export default TokenExpirationTestPage; 
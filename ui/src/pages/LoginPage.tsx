import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import styled from 'styled-components';
import { 
  FormContainer, 
  FormTitle, 
  Form, 
  FormGroup, 
  Label, 
  Input, 
  ErrorMessage,
  ButtonGroup,
  PrimaryButton
} from '../components/forms/FormComponents';
import { useAuth } from '../context/AuthContext';

const LoginPageContainer = styled.div`
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100%;
  padding: ${props => props.theme.spacing.xl};
`;

const LoginCard = styled.div`
  background-color: ${props => props.theme.colors.white};
  border-radius: ${props => props.theme.borderRadius.medium};
  box-shadow: ${props => props.theme.shadows.medium};
  width: 100%;
  max-width: 450px;
  padding: ${props => props.theme.spacing.xl};
`;

const RegisterLink = styled.div`
  margin-top: ${props => props.theme.spacing.lg};
  text-align: center;
  font-size: ${props => props.theme.fontSizes.medium};
  
  a {
    color: ${props => props.theme.colors.primary};
    text-decoration: none;
    
    &:hover {
      text-decoration: underline;
    }
  }
`;

const LoginPage: React.FC = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [formError, setFormError] = useState<string | null>(null);
  
  const { login, isLoading } = useAuth();
  const navigate = useNavigate();
  
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setFormError(null);
    
    // Simple validation
    if (!email || !password) {
      setFormError('Please enter both email and password');
      return;
    }
    
    try {
      await login({ email, password });
      navigate('/'); // Redirect to home page after successful login
    } catch (error: any) {
      setFormError(error.message || 'Login failed. Please try again.');
    }
  };
  
  return (
    <LoginPageContainer>
      <LoginCard>
        <FormTitle>Log In</FormTitle>
        
        {formError && <ErrorMessage>{formError}</ErrorMessage>}
        
        <Form onSubmit={handleSubmit}>
          <FormGroup>
            <Label htmlFor="email">Email</Label>
            <Input
              id="email"
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="Enter your email"
              required
            />
          </FormGroup>
          
          <FormGroup>
            <Label htmlFor="password">Password</Label>
            <Input
              id="password"
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="Enter your password"
              required
            />
          </FormGroup>
          
          <ButtonGroup>
            <PrimaryButton type="submit" disabled={isLoading}>
              {isLoading ? 'Logging in...' : 'Log In'}
            </PrimaryButton>
          </ButtonGroup>
        </Form>
        
        <RegisterLink>
          Don't have an account? <Link to="/register">Register here</Link>
        </RegisterLink>
      </LoginCard>
    </LoginPageContainer>
  );
};

export default LoginPage;
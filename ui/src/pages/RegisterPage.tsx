import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import styled from 'styled-components';
import {
  FormTitle,
  Form,
  FormGroup,
  Label,
  Input,
  ErrorMessage,
  ButtonGroup,
  PrimaryButton,
  // SecondaryButton,
  HelperText
} from '../components/forms/FormComponents';
import { useAuth } from '../context/AuthContext';

const RegisterPageContainer = styled.div`
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100%;
  padding: ${props => props.theme.spacing.xl};
`;

const RegisterCard = styled.div`
  background-color: ${props => props.theme.colors.white};
  border-radius: ${props => props.theme.borderRadius.medium};
  box-shadow: ${props => props.theme.shadows.medium};
  width: 100%;
  max-width: 450px;
  padding: ${props => props.theme.spacing.xl};
`;

const LoginLink = styled.div`
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

const RegisterPage: React.FC = () => {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [formError, setFormError] = useState<string | null>(null);
  
  const { register, isLoading } = useAuth();
  const navigate = useNavigate();
  
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setFormError(null);
    
    // Simple validation
    if (!name || !email || !password || !confirmPassword) {
      setFormError('Please fill in all fields');
      return;
    }
    
    if (password !== confirmPassword) {
      setFormError('Passwords do not match');
      return;
    }
    
    if (password.length < 8) {
      setFormError('Password must be at least 8 characters long');
      return;
    }
    
    try {
      await register({ name, email, password, confirmPassword });
      navigate('/'); // Redirect to home page after successful registration
    } catch (error: any) {
      setFormError(error.message || 'Registration failed. Please try again.');
    }
  };
  
  return (
    <RegisterPageContainer>
      <RegisterCard>
        <FormTitle>Create an Account</FormTitle>
        
        {formError && <ErrorMessage>{formError}</ErrorMessage>}
        
        <Form onSubmit={handleSubmit}>
          <FormGroup>
            <Label htmlFor="name">Name</Label>
            <Input
              id="name"
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="Enter your name"
              required
            />
          </FormGroup>
          
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
              placeholder="Create a password"
              required
            />
            <HelperText>Password must be at least 8 characters long</HelperText>
          </FormGroup>
          
          <FormGroup>
            <Label htmlFor="confirmPassword">Confirm Password</Label>
            <Input
              id="confirmPassword"
              type="password"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              placeholder="Confirm your password"
              required
            />
          </FormGroup>
          
          <ButtonGroup>
            <PrimaryButton type="submit" disabled={isLoading}>
              {isLoading ? 'Creating Account...' : 'Register'}
            </PrimaryButton>
          </ButtonGroup>
        </Form>
        
        <LoginLink>
          Already have an account? <Link to="/login">Log in here</Link>
        </LoginLink>
      </RegisterCard>
    </RegisterPageContainer>
  );
};

export default RegisterPage;
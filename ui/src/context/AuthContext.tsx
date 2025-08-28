import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { useNavigate } from 'react-router-dom';
import { 
  User, 
  LoginCredentials, 
  RegisterData, 
  login as loginApi, 
  register as registerApi,
  logout as logoutApi,
  getCurrentUser,
  isAuthenticated as checkAuth,
  initializeAuth
} from '../services/authService';

interface AuthContextType {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (credentials: LoginCredentials) => Promise<void>;
  register: (data: RegisterData) => Promise<void>;
  logout: () => void;
  error: string | null;
  clearError: () => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

interface AuthProviderProps {
  children: ReactNode;
}

export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const navigate = useNavigate();

  useEffect(() => {
    // Initialize auth state from localStorage
    initializeAuth();
    const currentUser = getCurrentUser();
    setUser(currentUser);
    setIsLoading(false);

    // Listen for token expiration events
    const handleTokenExpired = () => {
      setUser(null);
      setError('Your session has expired. Please log in again.');
      // Redirect to login page
      navigate('/login');
    };

    window.addEventListener('tokenExpired', handleTokenExpired);

    // Cleanup event listener
    return () => {
      window.removeEventListener('tokenExpired', handleTokenExpired);
    };
  }, [navigate]);

  const login = async (credentials: LoginCredentials) => {
    setError(null);
    try {
      setIsLoading(true);
      const response = await loginApi(credentials);
      setUser(response.user);
      // Redirect to home page after successful login
      navigate('/');
    } catch (err: any) {
      const errorMessage = err.message || 'Failed to login';
      setError(errorMessage);
      throw err;
    } finally {
      setIsLoading(false);
    }
  };

  const register = async (data: RegisterData) => {
    setError(null);
    try {
      setIsLoading(true);
      const response = await registerApi(data);
      setUser(response.user);
      // Redirect to home page after successful registration
      navigate('/');
    } catch (err: any) {
      const errorMessage = err.message || 'Failed to register';
      setError(errorMessage);
      throw err;
    } finally {
      setIsLoading(false);
    }
  };

  const logout = () => {
    logoutApi();
    setUser(null);
    setError(null);
    // Redirect to login page
    navigate('/login');
  };

  const clearError = () => {
    setError(null);
  };

  const value = {
    user,
    isAuthenticated: checkAuth(),
    isLoading,
    login,
    register,
    logout,
    error,
    clearError
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};

export const useAuth = (): AuthContextType => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
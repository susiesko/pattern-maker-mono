import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
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
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

interface AuthProviderProps {
  children: ReactNode;
}

export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    // Initialize auth state from localStorage
    initializeAuth();
    const currentUser = getCurrentUser();
    setUser(currentUser);
    setIsLoading(false);
  }, []);

  const login = async (credentials: LoginCredentials) => {
    setError(null);
    try {
      setIsLoading(true);
      const response = await loginApi(credentials);
      setUser(response.user);
    } catch (err: any) {
      setError(err.message || 'Failed to login');
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
    } catch (err: any) {
      setError(err.message || 'Failed to register');
      throw err;
    } finally {
      setIsLoading(false);
    }
  };

  const logout = () => {
    logoutApi();
    setUser(null);
  };

  const value = {
    user,
    isAuthenticated: checkAuth(),
    isLoading,
    login,
    register,
    logout,
    error
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
import api from './api';

export interface LoginCredentials {
  email: string;
  password: string;
}

export interface RegisterData {
  email: string;
  password: string;
  confirmPassword: string;
  name: string;
}

export interface User {
  id: string;
  email: string;
  name: string;
}

export interface AuthResponse {
  user: User;
  token: string;
}

const AUTH_TOKEN_KEY = 'auth_token';
const USER_DATA_KEY = 'user_data';

/**
 * Handles user login
 */
export const login = async (credentials: LoginCredentials): Promise<AuthResponse> => {
  const response = await api.post('/auth/login', credentials);
  const data = response.data;
  
  // Store the token and user data
  localStorage.setItem(AUTH_TOKEN_KEY, data.token);
  localStorage.setItem(USER_DATA_KEY, JSON.stringify(data.user));
  
  // Update the API headers with the new token
  api.defaults.headers.common['Authorization'] = `Bearer ${data.token}`;
  
  return data;
};

/**
 * Handles user registration
 */
export const register = async (userData: RegisterData): Promise<AuthResponse> => {
  const response = await api.post('/auth/register', userData);
  const data = response.data;
  
  // Store the token and user data
  localStorage.setItem(AUTH_TOKEN_KEY, data.token);
  localStorage.setItem(USER_DATA_KEY, JSON.stringify(data.user));
  
  // Update the API headers with the new token
  api.defaults.headers.common['Authorization'] = `Bearer ${data.token}`;
  
  return data;
};

/**
 * Logs out the current user
 */
export const logout = (): void => {
  localStorage.removeItem(AUTH_TOKEN_KEY);
  localStorage.removeItem(USER_DATA_KEY);
  
  // Remove the Authorization header
  delete api.defaults.headers.common['Authorization'];
};

/**
 * Gets the current authentication token
 */
export const getToken = (): string | null => {
  return localStorage.getItem(AUTH_TOKEN_KEY);
};

/**
 * Gets the current user data
 */
export const getCurrentUser = (): User | null => {
  const userData = localStorage.getItem(USER_DATA_KEY);
  return userData ? JSON.parse(userData) : null;
};

/**
 * Checks if the user is authenticated
 */
export const isAuthenticated = (): boolean => {
  return !!getToken();
};

/**
 * Initialize the auth state from localStorage
 */
export const initializeAuth = (): void => {
  const token = getToken();
  if (token) {
    api.defaults.headers.common['Authorization'] = `Bearer ${token}`;
  }
};
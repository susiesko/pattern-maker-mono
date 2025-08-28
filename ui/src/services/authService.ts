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
 * Decodes a JWT token to extract payload
 */
const decodeToken = (token: string): any => {
  try {
    const base64Url = token.split('.')[1];
    const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');
    const jsonPayload = decodeURIComponent(atob(base64).split('').map(c => {
      return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
    }).join(''));
    return JSON.parse(jsonPayload);
  } catch (error) {
    console.error('Error decoding token:', error);
    return null;
  }
};

/**
 * Checks if a token is expired
 */
export const isTokenExpired = (token: string): boolean => {
  const payload = decodeToken(token);
  if (!payload || !payload.exp) {
    return true;
  }
  
  const currentTime = Math.floor(Date.now() / 1000);
  return payload.exp < currentTime;
};

/**
 * Gets token expiration time
 */
export const getTokenExpiration = (token: string): Date | null => {
  const payload = decodeToken(token);
  if (!payload || !payload.exp) {
    return null;
  }
  
  return new Date(payload.exp * 1000);
};

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
 * Checks if the user is authenticated and token is valid
 */
export const isAuthenticated = (): boolean => {
  const token = getToken();
  if (!token) {
    return false;
  }
  
  // Check if token is expired
  if (isTokenExpired(token)) {
    // Auto-logout if token is expired
    logout();
    return false;
  }
  
  return true;
};

/**
 * Initialize the auth state from localStorage
 */
export const initializeAuth = (): void => {
  const token = getToken();
  if (token) {
    // Check if token is expired before setting it
    if (isTokenExpired(token)) {
      logout();
      return;
    }
    api.defaults.headers.common['Authorization'] = `Bearer ${token}`;
  }
};
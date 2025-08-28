import { describe, it, expect, beforeEach, vi } from 'vitest';
import { 
  isTokenExpired, 
  getTokenExpiration, 
  isAuthenticated, 
  logout,
} from './authService';

// Mock localStorage
const localStorageMock = {
  getItem: vi.fn(),
  setItem: vi.fn(),
  removeItem: vi.fn(),
  clear: vi.fn(),
};
Object.defineProperty(window, 'localStorage', {
  value: localStorageMock,
});

// Mock window.dispatchEvent
const dispatchEventMock = vi.fn();
Object.defineProperty(window, 'dispatchEvent', {
  value: dispatchEventMock,
});

describe('authService', () => {
  beforeEach(() => {
    vi.clearAllMocks();
    localStorageMock.getItem.mockReturnValue(null);
  });

  describe('isTokenExpired', () => {
    it('should return true for expired token', () => {
      // Create a token that expired 1 hour ago
      const expiredTime = Math.floor(Date.now() / 1000) - 3600;
      const expiredToken = `header.${btoa(JSON.stringify({ exp: expiredTime }))}.signature`;
      
      expect(isTokenExpired(expiredToken)).toBe(true);
    });

    it('should return false for valid token', () => {
      // Create a token that expires in 1 hour
      const futureTime = Math.floor(Date.now() / 1000) + 3600;
      const validToken = `header.${btoa(JSON.stringify({ exp: futureTime }))}.signature`;
      
      expect(isTokenExpired(validToken)).toBe(false);
    });

    it('should return true for invalid token', () => {
      expect(isTokenExpired('invalid.token')).toBe(true);
    });

    it('should return true for token without exp claim', () => {
      const tokenWithoutExp = `header.${btoa(JSON.stringify({ sub: 'user123' }))}.signature`;
      expect(isTokenExpired(tokenWithoutExp)).toBe(true);
    });
  });

  describe('getTokenExpiration', () => {
    it('should return expiration date for valid token', () => {
      const expTime = Math.floor(Date.now() / 1000) + 3600;
      const token = `header.${btoa(JSON.stringify({ exp: expTime }))}.signature`;
      
      const expiration = getTokenExpiration(token);
      expect(expiration).toBeInstanceOf(Date);
      expect(expiration?.getTime()).toBe(expTime * 1000);
    });

    it('should return null for invalid token', () => {
      expect(getTokenExpiration('invalid.token')).toBeNull();
    });
  });

  describe('isAuthenticated', () => {
    it('should return false when no token exists', () => {
      localStorageMock.getItem.mockReturnValue(null);
      expect(isAuthenticated()).toBe(false);
    });

    it('should return false when token is expired', () => {
      const expiredTime = Math.floor(Date.now() / 1000) - 3600;
      const expiredToken = `header.${btoa(JSON.stringify({ exp: expiredTime }))}.signature`;
      localStorageMock.getItem.mockReturnValue(expiredToken);
      
      expect(isAuthenticated()).toBe(false);
      // Should have called logout due to expired token
      expect(localStorageMock.removeItem).toHaveBeenCalledWith('auth_token');
      expect(localStorageMock.removeItem).toHaveBeenCalledWith('user_data');
    });

    it('should return true when token is valid', () => {
      const futureTime = Math.floor(Date.now() / 1000) + 3600;
      const validToken = `header.${btoa(JSON.stringify({ exp: futureTime }))}.signature`;
      localStorageMock.getItem.mockReturnValue(validToken);
      
      expect(isAuthenticated()).toBe(true);
    });
  });



  describe('logout', () => {
    it('should clear localStorage', () => {
      logout();
      
      expect(localStorageMock.removeItem).toHaveBeenCalledWith('auth_token');
      expect(localStorageMock.removeItem).toHaveBeenCalledWith('user_data');
    });
  });
}); 
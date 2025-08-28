import axios from 'axios';

// Define a custom error class to include the response property
class ApiError extends Error {
  response: unknown;

  constructor(message: string, response: unknown) {
    super(message);
    this.name = 'ApiError';
    this.response = response;
  }
}

// Determine the API base URL based on environment
const getBaseUrl = () => {
  // In development, use the proxy defined in vite.config.ts
  if (import.meta.env.DEV) {
    return '/api/v1';
  }

  // In production, use the environment variable if available, or default to relative path
  return import.meta.env.VITE_API_URL || '/api/v1';
};

// Helper function to determine if we should log verbose messages
const isDebugMode = () => {
  return import.meta.env.VITE_LOG_LEVEL === 'debug';
};

// Create an axios instance with default config
const api = axios.create({
  baseURL: getBaseUrl(),
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
});

// Add a request interceptor for handling common request tasks
api.interceptors.request.use(
  (config) => {
    // Log request in debug mode
    if (isDebugMode()) {
      console.log('API Request:', {
        url: config.url,
        method: config.method?.toUpperCase(),
        headers: config.headers,
        data: config.data
      });
    }

    // Add authentication token if available
    const token = localStorage.getItem('auth_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    console.error('Request Error:', error);
    return Promise.reject(error);
  }
);

// Add a response interceptor for handling common response tasks
api.interceptors.response.use(
  (response) => {
    // Log response in debug mode
    if (isDebugMode()) {
      console.log('API Response:', {
        url: response.config.url,
        method: response.config.method?.toUpperCase(),
        status: response.status,
        data: response.data
      });
    }

    // Check if the response has the expected structure
    if (response.data && typeof response.data === 'object') {
      // If the API returns a success property, use it
      if ('success' in response.data && !response.data.success) {
        // If the API explicitly says the request was not successful
        const errorMessage = response.data.message || response.data.errors?.join(', ') || 'Unknown error';
        console.error('API Error:', errorMessage);

        // Create a custom error object with the API error details
        const customError = new ApiError(errorMessage, response);
        return Promise.reject(customError);
      }
    }

    return response;
  },
  (error) => {
    // Handle common errors here
    if (error.response) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx
      const status = error.response.status;
      const data = error.response.data;
      let errorMessage = 'An error occurred';

      if (status === 401) {
        console.warn('Authentication Error (401): Token may be expired or invalid');
        const isTokenError = data?.message?.includes('token') || 
                           data?.message?.includes('expired') ||
                           data?.message?.includes('unauthorized') ||
                           errorMessage.toLowerCase().includes('token') ||
                           errorMessage.toLowerCase().includes('expired') ||
                           errorMessage.toLowerCase().includes('unauthorized');
        if (isTokenError) {
          // Handle token expiration directly here to avoid circular import
          localStorage.removeItem('auth_token');
          localStorage.removeItem('user_data');
          delete api.defaults.headers.common['Authorization'];
          window.dispatchEvent(new CustomEvent('tokenExpired'));
          errorMessage = 'Your session has expired. Please log in again.';
        }
      } else if (status === 404) {
        errorMessage = 'Resource not found';
      } else if (status === 422) {
        // Handle validation errors
        if (data && data.errors) {
          errorMessage = Object.values(data.errors).flat().join(', ');
        } else {
          errorMessage = data?.message || 'Validation error';
        }
      } else if (status >= 500) {
        errorMessage = 'Server error. Please try again later.';
      } else {
        errorMessage = data?.message || `HTTP ${status} error`;
      }

      console.error('API Error:', {
        status,
        message: errorMessage,
        data
      });

      // Create a custom error object with the API error details
      const customError = new ApiError(errorMessage, error.response);
      return Promise.reject(customError);
    } else if (error.request) {
      // The request was made but no response was received
      console.error('Network Error:', error.request);
      const customError = new ApiError('Network error. Please check your connection.', error.request);
      return Promise.reject(customError);
    } else {
      // Something happened in setting up the request that triggered an Error
      console.error('Request Setup Error:', error.message);
      const customError = new ApiError(error.message || 'Request setup error', error);
      return Promise.reject(customError);
    }
  }
);

export default api;
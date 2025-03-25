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

    // You could add authentication tokens here if needed
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

      let errorMessage = 'An error occurred with the API request';

      // Try to extract a meaningful error message
      if (data) {
        if (data.message) {
          errorMessage = data.message;
        } else if (data.errors && Array.isArray(data.errors)) {
          errorMessage = data.errors.join(', ');
        } else if (typeof data === 'string') {
          errorMessage = data;
        }
      }

      // Log with appropriate level based on status code
      if (status >= 500) {
        console.error(`Server Error (${status}):`, errorMessage);
      } else if (status === 401 || status === 403) {
        console.warn(`Authentication Error (${status}):`, errorMessage);
      } else {
        console.error(`API Error (${status}):`, errorMessage);
      }

      // Enhance the error object with more context
      error.message = errorMessage;
      error.statusCode = status;
    } else if (error.request) {
      // The request was made but no response was received
      console.error('Network Error: No response received', error.request);
      error.message = 'Network error: Unable to connect to the server';
    } else {
      // Something happened in setting up the request that triggered an Error
      console.error('Request Error:', error.message);
    }

    return Promise.reject(error);
  }
);

export default api;
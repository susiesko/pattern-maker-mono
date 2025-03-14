import axios from 'axios';

// Create an axios instance with default config
const api = axios.create({
  baseURL: '/api/v1', // This will be proxied in development
  headers: {
    'Content-Type': 'application/json',
  },
});

// Add a request interceptor for handling common request tasks
api.interceptors.request.use(
  (config) => {
    // You could add authentication tokens here if needed
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Add a response interceptor for handling common response tasks
api.interceptors.response.use(
  (response) => {
    return response;
  },
  (error) => {
    // Handle common errors here
    if (error.response) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx
      console.error('API Error:', error.response.data);
    } else if (error.request) {
      // The request was made but no response was received
      console.error('Network Error:', error.request);
    } else {
      // Something happened in setting up the request that triggered an Error
      console.error('Request Error:', error.message);
    }
    return Promise.reject(error);
  }
);

export default api;
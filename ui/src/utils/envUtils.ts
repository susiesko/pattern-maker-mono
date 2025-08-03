/**
 * Environment utilities for development vs production
 */

export const isDevelopment = () => import.meta.env.DEV;
export const isProduction = () => import.meta.env.PROD;

/**
 * Only execute a function in development
 */
export const devOnly = <T>(fn: () => T): T | undefined => {
  if (isDevelopment()) {
    return fn();
  }
  return undefined;
};

/**
 * Get environment info for debugging
 */
export const getEnvironmentInfo = () => ({
  isDev: isDevelopment(),
  isProd: isProduction(),
  mode: import.meta.env.MODE,
  baseUrl: import.meta.env.BASE_URL,
}); 
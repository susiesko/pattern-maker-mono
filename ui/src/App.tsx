import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ThemeProvider } from 'styled-components';
import theme from './styles/theme';
import GlobalStyles from './styles/GlobalStyles';
import Layout from './components/Layout';
import WelcomePage from './components/WelcomePage';
import BeadsListPage from './pages/BeadsListPage';
import BeadDetailPage from './pages/BeadDetailPage';
import AddBeadPage from './pages/AddBeadPage';
import EditBeadPage from './pages/EditBeadPage';
import ComingSoon from './components/ComingSoon';
import LoginPage from './pages/LoginPage';
import RegisterPage from './pages/RegisterPage';
// Only import dev routes in development
const DevRoutes = import.meta.env.DEV 
  ? React.lazy(() => import('./routes/devRoutes').then(module => ({ default: module.DevRoutes })))
  : null;
import ProtectedRoute from './components/ProtectedRoute';
import AuthErrorToast from './components/ui/AuthErrorToast';
import { AuthProvider } from './context/AuthContext';

// Create a client for React Query
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      refetchOnWindowFocus: false,
      retry: (failureCount, error: any) => {
        // Don't retry on 4xx errors (client errors)
        if (error.statusCode >= 400 && error.statusCode < 500) {
          return false;
        }
        // Retry up to 2 times for other errors
        return failureCount < 2;
      },
      staleTime: 5 * 60 * 1000, // 5 minutes
      gcTime: 10 * 60 * 1000, // 10 minutes
    },
    mutations: {
      // Don't retry mutations by default
      retry: false,
    },
  },
});

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <ThemeProvider theme={theme}>
        <GlobalStyles />
        <BrowserRouter>
          <AuthProvider>
            <AuthErrorToast />
            <Routes>
              {/* Public routes */}
              <Route path="/login" element={<LoginPage />} />
              <Route path="/register" element={<RegisterPage />} />

              {/* Layout with navigation */}
              <Route path="/" element={<Layout />}>
                {/* Public routes within layout */}
                <Route index element={<WelcomePage />} />
                <Route path="beads" element={<BeadsListPage />} />
                <Route path="beads/:id" element={<BeadDetailPage />} />

                {/* Protected routes */}
                <Route element={<ProtectedRoute />}>
                  <Route path="beads/add" element={<AddBeadPage />} />
                  <Route path="beads/edit/:id" element={<EditBeadPage />} />
                  <Route path="designer" element={<ComingSoon title="Pattern Designer" />} />
                  <Route path="projects" element={<ComingSoon title="My Projects" />} />
                </Route>

                {/* Development/Testing routes */}
                {import.meta.env.DEV && DevRoutes && <DevRoutes />}

                {/* Catch-all redirect */}
                <Route path="*" element={<Navigate to="/" replace />} />
              </Route>
            </Routes>
          </AuthProvider>
        </BrowserRouter>
      </ThemeProvider>
    </QueryClientProvider>
  );
}

export default App;

import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ThemeProvider } from 'styled-components';
import theme from './styles/theme';
import GlobalStyles from './styles/GlobalStyles';
import Layout from './components/Layout';
import WelcomePage from './components/WelcomePage';
import BeadsList from './components/search/BeadsList.tsx';
import AddBeadPage from './pages/AddBeadPage';
import EditBeadPage from './pages/EditBeadPage';
import ComingSoon from './components/ComingSoon';
import LoginPage from './pages/LoginPage';
import RegisterPage from './pages/RegisterPage';
import ProtectedRoute from './components/ProtectedRoute';
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
      cacheTime: 10 * 60 * 1000, // 10 minutes
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
        <AuthProvider>
          <BrowserRouter>
            <Routes>
              {/* Public routes */}
              <Route path="/login" element={<LoginPage />} />
              <Route path="/register" element={<RegisterPage />} />

              {/* Layout with navigation */}
              <Route path="/" element={<Layout />}>
                {/* Public routes within layout */}
                <Route index element={<WelcomePage />} />
                <Route path="beads" element={<BeadsList />} />

                {/* Protected routes */}
                <Route element={<ProtectedRoute />}>
                  <Route path="beads/add" element={<AddBeadPage />} />
                  <Route path="beads/edit/:id" element={<EditBeadPage />} />
                  <Route path="designer" element={<ComingSoon title="Pattern Designer" />} />
                  <Route path="projects" element={<ComingSoon title="My Projects" />} />
                </Route>

                {/* Catch-all redirect */}
                <Route path="*" element={<Navigate to="/" replace />} />
              </Route>
            </Routes>
          </BrowserRouter>
        </AuthProvider>
      </ThemeProvider>
    </QueryClientProvider>
  );
}

export default App;

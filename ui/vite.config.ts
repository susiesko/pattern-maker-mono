import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      // Proxy API requests to the Rails server
      '/api': {
        target: 'http://localhost:3000', // Rails server running on port 3000
        changeOrigin: true,
        secure: false,
      },
    },
  },
})

import {defineConfig} from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'
import tsconfigPaths from 'vite-tsconfig-paths'

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    react(),
    tsconfigPaths()
  ],
  /* TODO: address aliases*/
  resolve: {
    alias: {
      '@': path.resolve(__dirname, '../'),
      '@src': path.resolve(__dirname, '../src'),
      '@components': path.resolve(__dirname, '../src/components'),
      '@hooks': path.resolve(__dirname, '../src/hooks'),
      '@types': path.resolve(__dirname, '../src/types'),
      '@utils': path.resolve(__dirname, '../src/utils'),
    },
  },
  server: {
    port: 5173,
    host: '0.0.0.0',
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

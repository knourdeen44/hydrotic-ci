/// <reference types="vitest/config" />
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  // Tests unitaires seulement (les parcours Playwright sont dans tests/).
  test: { include: ['src/**/*.test.ts'] },
})

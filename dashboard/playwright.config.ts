import { defineConfig, devices } from '@playwright/test'

// Tests du tableau de bord sur le serveur de développement Vite (aucun appel réseau externe).
export default defineConfig({
  testDir: './tests',
  // Captures sans suffixe de plateforme : les captures de non-régression sont générées en CI (Linux).
  snapshotPathTemplate: '{testDir}/captures/{arg}{ext}',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  reporter: process.env.CI ? [['list'], ['html', { open: 'never' }]] : 'list',
  use: {
    baseURL: 'http://localhost:4173',
    trace: 'retain-on-failure',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'], viewport: { width: 1440, height: 880 }, deviceScaleFactor: 1 },
    },
  ],
  webServer: {
    command: 'npx vite --port 4173 --strictPort',
    url: 'http://localhost:4173',
    reuseExistingServer: !process.env.CI,
  },
})

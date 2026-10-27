#!/usr/bin/env node
// Ouvre chaque écran du site compilé (application Flutter web et tableau de bord) et échoue si une
// requête part ailleurs que vers le serveur local ou les services autorisés de la phase 2
// (API Hydrotic, connexion Clerk, tuiles OpenStreetMap). CanvasKit, polices, CDN : interdits.
// Usage : node tools/verifier_web.mjs http://127.0.0.1:8080/hydrotic-ci
// Utilise le Playwright du tableau de bord (npm ci + npx playwright install chromium au préalable).
import { createRequire } from 'node:module'

const require = createRequire(new URL('../dashboard/package.json', import.meta.url))
const { chromium } = require('@playwright/test')

const base = process.argv[2]
if (!base) throw new Error('Usage : node tools/verifier_web.mjs <adresse du site>')

const ecrans = [
  ...['demarrage', '', 'carte', 'alertes', 'profil', 'signaler', 'sos', 'demo/verrouille'].map((r) => `app/#/${r}`),
  ...['', 'alertes', 'sos', 'signalements', 'previsions', 'historique', 'zones', 'supervision'].map((r) => `dashboard/#/${r}`),
]

const HOTES = [
  'hydrotic-ci-api.vercel.app',
  'clerk.accounts.dev',
  'img.clerk.com',
  'clerk-telemetry.com',
  'challenges.cloudflare.com', // protection anti-robots de Clerk
  'tile.openstreetmap.org',
]
const autorise = (url) => {
  const hote = new URL(url).hostname
  return HOTES.some((h) => hote === h || hote.endsWith(`.${h}`))
}

const navigateur = await chromium.launch()
const contactes = new Set()
const externes = []
for (const ecran of ecrans) {
  const page = await navigateur.newPage({ viewport: { width: 1280, height: 800 } })
  page.on('request', (requete) => {
    const url = requete.url()
    if (url.startsWith(base) || /^(data|blob):/.test(url)) return
    if (autorise(url)) contactes.add(new URL(url).hostname)
    else externes.push(`${ecran} → ${url}`)
  })
  await page.goto(`${base}/${ecran}`)
  // Flutter web : démarrage du moteur et premier rendu.
  await page.waitForTimeout(ecran.startsWith('app') ? 4000 : 1000)
  await page.close()
}
await navigateur.close()

if (externes.length) {
  console.error(`Requêtes externes (${externes.length}) :\n${externes.join('\n')}`)
  process.exit(1)
}
console.log(`Aucune requête non autorisée sur ${ecrans.length} écrans.`)
console.log(`Services contactés : ${[...contactes].join(', ') || 'aucun'}.`)

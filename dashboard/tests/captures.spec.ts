import { existsSync } from 'node:fs'
import { expect, test } from '@playwright/test'

// Comparaisons visuelles. Les polices sont celles du projet (@fontsource/inter), pas du système.

test('@reference D1 à 1440 × 880 comparé à 02_dashboard_vue_ensemble.png', async ({ browser }) => {
  // La capture de référence est rendue à 2× : même densité ici.
  const page = await browser.newPage({ viewport: { width: 1440, height: 880 }, deviceScaleFactor: 2 })
  await page.goto('http://localhost:4173/')
  await expect(page.getByText('Treichville, av. 21')).toBeVisible()
  await page.evaluate(() => document.fonts.ready)
  // Tolérance : lissage du texte différent d'un système à l'autre, mention « données fictives »
  // ajoutée en pied de barre latérale (absente de la maquette).
  await expect(page).toHaveScreenshot('reference-d1.png', { scale: 'device', maxDiffPixelRatio: 0.04, threshold: 0.3 })
  await page.close()
})

// Captures de non-régression des écrans D1 à D8 : générées et vérifiées en CI uniquement (rendu Linux).
const ecrans: [string, string][] = [
  ['d1', '/'],
  ['d2', '/#/alertes'],
  ['d3', '/#/sos'],
  ['d4', '/#/signalements'],
  ['d5', '/#/previsions'],
  ['d6', '/#/historique'],
  ['d7', '/#/zones'],
  ['d8', '/#/supervision'],
]
for (const [nom, chemin] of ecrans) {
  test(`@regression ${nom}`, async ({ page }) => {
    test.skip(!process.env.CI, 'Captures de non-régression vérifiées en CI uniquement')
    const miseAJour = ['all', 'changed'].includes(test.info().config.updateSnapshots)
    test.skip(!miseAJour && !existsSync(test.info().snapshotPath(`${nom}.png`)), 'Capture pas encore générée')
    await page.goto(chemin)
    await expect(page.getByRole('heading', { level: 1 })).not.toHaveText('')
    await page.evaluate(() => document.fonts.ready)
    await expect(page).toHaveScreenshot(`${nom}.png`)
  })
}

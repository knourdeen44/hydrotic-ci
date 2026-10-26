import { expect, test } from '@playwright/test'

// Aucun appel réseau hors du serveur local (phase 1 : ni API, ni police chargée à distance).
test.beforeEach(async ({ page, baseURL }) => {
  page.on('request', (requete) => {
    const url = requete.url()
    if (!url.startsWith(baseURL!) && !url.startsWith('data:')) throw new Error(`Appel réseau inattendu : ${url}`)
  })
})

test.describe('D1 — Vue d’ensemble', () => {
  test('en-tête, indicateurs, carte, alerte en attente et SOS', async ({ page }) => {
    await page.goto('/')
    await expect(page.getByRole('heading', { name: "Vue d'ensemble", level: 1 })).toBeVisible()
    await expect(page.getByText('Mercredi 17 juin · mise à jour il y a 2 min · Agent : ONPC Abidjan Sud')).toBeVisible()
    for (const libelle of ['Zones en alerte', 'SOS actifs', 'Signalements confirmés', 'Alertes délivrées']) {
      await expect(page.getByText(libelle, { exact: true })).toBeVisible()
    }
    await expect(page.getByText('86 %')).toBeVisible()
    await expect(page.getByRole('img', { name: 'Carte des risques, signalements et victimes' })).toBeVisible()
    await expect(page.getByText('ROUGE · Riviera Palmeraie')).toBeVisible()
    await expect(page.getByText(/probabilité 0,82, 7 signalements confirmés rue Ministre/)).toBeVisible()
    await expect(page.getByRole('row')).toHaveCount(5)
  })

  test('« Valider et envoyer » passe l’alerte à « Envoyée »', async ({ page }) => {
    await page.goto('/')
    const menuAlertes = page.getByRole('link', { name: /^Alertes/ })
    await expect(menuAlertes).toContainText('1')
    await page.getByRole('button', { name: 'Valider et envoyer' }).click()
    await expect(page.getByText('✓ Envoyée · push + e-mail')).toBeVisible()
    await expect(page.getByRole('button', { name: 'Valider et envoyer' })).toHaveCount(0)
    await expect(menuAlertes).not.toContainText('1')
  })

  test('un clic sur un statut le fait avancer (Reçu → En route → Secouru)', async ({ page }) => {
    await page.goto('/')
    const ligne = page.getByRole('row', { name: /17:12/ })
    await ligne.getByRole('button', { name: 'Reçu' }).click()
    await ligne.getByRole('button', { name: 'En route' }).click()
    await expect(ligne.getByText('Secouru')).toBeVisible()
  })

  test('« + Alerte manuelle » : message « prochaine version »', async ({ page }) => {
    await page.goto('/')
    await page.getByRole('button', { name: '+ Alerte manuelle' }).click()
    await expect(page.getByRole('status')).toHaveText('Disponible dans une prochaine version')
  })
})

test.describe('D2 à D8', () => {
  const pages: [string, string, RegExp | string][] = [
    ['Alertes', '#/alertes', 'ALERTE ROUGE — Riviera Palmeraie'],
    ['SOS victimes', '#/sos', 'Carte des victimes'],
    ['Signalements', '#/signalements', 'Rue Ministre'],
    ['Prévisions', '#/previsions', 'Pluie (mm) — 5 derniers jours et prévision'],
    ['Historique & export', '#/historique', 'Vigilance jaune — Treichville'],
    ['Zones et seuils', '#/zones', '> 70 %'],
    ['Supervision', '#/supervision', 'Collecte des données'],
  ]
  for (const [titre, chemin, contenu] of pages) {
    test(`menu → ${titre}`, async ({ page }) => {
      await page.goto('/')
      await page.getByRole('link', { name: new RegExp(`^${titre.replace(/[&]/g, '\\$&')}`) }).click()
      await expect(page).toHaveURL(new RegExp(`${chemin.replace('#', '#')}$`))
      await expect(page.getByRole('heading', { name: titre, level: 1 })).toBeVisible()
      await expect(page.getByText(contenu).first()).toBeVisible()
    })
  }

  test('D2 — filtre par zone et par niveau', async ({ page }) => {
    await page.goto('/#/alertes')
    await expect(page.getByRole('row')).toHaveCount(4)
    await page.getByLabel('Filtrer par zone').selectOption('treichville')
    await expect(page.getByRole('row')).toHaveCount(3)
    await page.getByLabel('Filtrer par niveau').selectOption('jaune')
    await expect(page.getByRole('row')).toHaveCount(2)
  })

  test('D6 — « Exporter en CSV » : message « prochaine version »', async ({ page }) => {
    await page.goto('/#/historique')
    await page.getByRole('button', { name: 'Exporter en CSV' }).click()
    await expect(page.getByRole('status')).toHaveText('Disponible dans une prochaine version')
  })

  test('D8 — services non connectés', async ({ page }) => {
    await page.goto('/#/supervision')
    await expect(page.getByText('Non connecté (phase 1)')).toHaveCount(3)
  })
})

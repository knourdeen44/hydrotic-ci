import { expect, test, type Page } from '@playwright/test'

const kpiSos = (page: Page) => page.getByText('SOS actifs', { exact: true }).locator('..')

test.describe('Mode démo (Ctrl + D)', () => {
  test('le menu liste les 4 scénarios et la réinitialisation', async ({ page }) => {
    await page.goto('/')
    await page.keyboard.press('Control+d')
    const menu = page.getByRole('dialog', { name: 'Mode démonstration' })
    await expect(menu).toBeVisible()
    for (const entree of [
      'Scénario 1 — Alerte la veille',
      'Scénario 2 — Confirmation rue Ministre',
      'Scénario 3 — SOS',
      'Scénario 4 — Tableau de bord',
      'Réinitialiser les données',
    ]) {
      await expect(menu.getByText(entree)).toBeVisible()
    }
    // Scénarios 1 à 3 : application mobile, dans un nouvel onglet.
    await expect(menu.getByRole('link', { name: /Scénario 3/ })).toHaveAttribute('href', '../app/#/sos?demo=sos')
    await page.keyboard.press('Escape')
    await expect(menu).toHaveCount(0)
  })

  test('scénario 4 : arrivée d’un SOS, validation de l’alerte, passage « En route »', async ({ page }) => {
    await page.clock.install()
    await page.goto('/')
    await page.keyboard.press('Control+d')
    await page.getByRole('button', { name: 'Scénario 4 — Tableau de bord' }).click()

    // Départ : le SOS de 17:12 n'est pas encore arrivé.
    await expect(page.getByRole('row', { name: /17:12/ })).toHaveCount(0)
    await expect(kpiSos(page)).toContainText('3')
    await expect(kpiSos(page)).toContainText('1 non pris en charge')
    await expect(page.getByRole('link', { name: /^SOS victimes/ })).toContainText('3')

    await page.clock.runFor(1600)
    await expect(page.getByRole('row', { name: /17:12/ })).toBeVisible()
    await expect(kpiSos(page)).toContainText('4')
    await expect(kpiSos(page)).toContainText('2 non pris en charge')
    await expect(page.getByRole('link', { name: /^SOS victimes/ })).toContainText('4')

    await page.clock.runFor(3400)
    await expect(page.getByText('✓ Envoyée · push + e-mail')).toBeVisible()

    await page.clock.runFor(2300)
    await expect(page.getByRole('row', { name: /17:12/ }).getByText('En route')).toBeVisible()
    await expect(kpiSos(page)).toContainText('1 non pris en charge')
  })

  test('réinitialiser remet l’alerte en attente et les statuts', async ({ page }) => {
    await page.goto('/#/alertes')
    await page.getByRole('link', { name: "Vue d'ensemble" }).click()
    await page.getByRole('button', { name: 'Valider et envoyer' }).click()
    await page.getByRole('row', { name: /17:08/ }).getByRole('button', { name: 'Reçu' }).click()
    await expect(page.getByText('✓ Envoyée · push + e-mail')).toBeVisible()

    await page.keyboard.press('Control+d')
    await page.getByRole('button', { name: 'Réinitialiser les données' }).click()
    await expect(page.getByRole('button', { name: 'Valider et envoyer' })).toBeVisible()
    await expect(page.getByRole('row', { name: /17:08/ }).getByText('Reçu')).toBeVisible()
  })
})

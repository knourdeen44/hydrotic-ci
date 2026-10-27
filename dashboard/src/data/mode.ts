// Mode de données : « api » (site publié : connexion Clerk + API Hydrotic) ou « demo »
// (données fictives : tests, comparaison aux maquettes, scénarios du mode démo).

const CLE = 'hydrotic-mode'

function choixLocal(): string | null {
  try {
    return window.localStorage.getItem(CLE)
  } catch {
    return null
  }
}

const apiConfiguree = Boolean(import.meta.env.VITE_API_URL && import.meta.env.VITE_CLERK_PUBLISHABLE_KEY)

export const MODE: 'api' | 'demo' =
  import.meta.env.VITE_DONNEES === 'demo' || choixLocal() === 'demo' || !apiConfiguree ? 'demo' : 'api'

/** Bascule de mode (menu démo) puis rechargement de la page. */
export function changerMode(mode: 'api' | 'demo'): void {
  try {
    if (mode === 'demo') window.localStorage.setItem(CLE, 'demo')
    else window.localStorage.removeItem(CLE)
  } catch {
    // Stockage indisponible : le mode reste celui de la configuration.
  }
  window.location.reload()
}

export const peutBasculer = apiConfiguree && import.meta.env.VITE_DONNEES !== 'demo'

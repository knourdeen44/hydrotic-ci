import { useEffect, useState } from 'react'

/** Charge des données asynchrones (dépôts) ; `undefined` tant qu'elles ne sont pas prêtes. */
export function useDonnees<T>(charger: () => Promise<T>): T | undefined {
  const [donnees, setDonnees] = useState<T>()
  useEffect(() => {
    let actif = true
    charger().then((d) => {
      if (actif) setDonnees(d)
    })
    return () => {
      actif = false
    }
    // Chargement unique : les dépôts « mock » ne changent pas pendant la session.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])
  return donnees
}

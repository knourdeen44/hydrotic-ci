import { useCallback, useEffect, useMemo, useRef, useState, type ReactNode } from 'react'
import { repositories } from '../data'
import { statutSosSuivant, type Sos } from '../data/models'
import { MODE } from '../data/mode'
import Toast from '../components/Toast'
import { fr } from '../i18n/fr'
import { cleSos, EtatContext, type Etat } from './etat'

// Scénario 4 : délais du prototype s4_dashboard.html.
const ARRIVEE_SOS = 1500
const VALIDATION_ALERTE = 4850
const PRISE_EN_CHARGE = 7200
// Mode réel : rafraîchissement des SOS (« temps réel »).
const RAFRAICHISSEMENT_MS = 5000

export default function EtatProvider({ children }: { children: ReactNode }) {
  const [initiaux, setInitiaux] = useState<Sos[]>()
  const [modifies, setModifies] = useState<Sos[]>()
  const [nouveauSos, setNouveauSos] = useState<string>()
  const [alerteValidee, setAlerteValidee] = useState(false)
  const [message, setMessage] = useState<string>()
  const minuterie = useRef<number | undefined>(undefined)
  const scenario = useRef<number[]>([])

  const toast = useCallback((texte: string) => {
    setMessage(texte)
    window.clearTimeout(minuterie.current)
    minuterie.current = window.setTimeout(() => setMessage(undefined), 3000)
  }, [])

  const recharger = useCallback(async () => {
    try {
      const liste = await repositories.sos.liste()
      // Mode réel : les SOS déjà secourus quittent la liste, la carte et le badge.
      setInitiaux(MODE === 'api' ? liste.filter((s) => s.statut !== 'SECOURU') : liste)
      if (MODE === 'api') setModifies(undefined)
    } catch {
      if (MODE === 'api') toast(fr.erreurChargement)
    }
  }, [toast])

  useEffect(() => {
    void recharger()
    if (MODE !== 'api') return
    const id = window.setInterval(() => void recharger(), RAFRAICHISSEMENT_MS)
    // Retour sur l'onglet : mise à jour immédiate.
    const auRetour = () => {
      if (document.visibilityState === 'visible') void recharger()
    }
    document.addEventListener('visibilitychange', auRetour)
    return () => {
      window.clearInterval(id)
      document.removeEventListener('visibilitychange', auRetour)
    }
  }, [recharger])

  const sos = modifies ?? initiaux

  const avancerSos = useCallback(
    (index: number) => {
      const cible = (modifies ?? initiaux ?? [])[index]
      if (!cible) return
      // Affichage immédiat, puis enregistrement (mode réel).
      setModifies((courant) =>
        (courant ?? initiaux ?? []).map((s, i) => (i === index ? { ...s, statut: statutSosSuivant(s.statut) } : s)),
      )
      if (MODE === 'api')
        repositories.sos.avancer(cible).then(recharger, (e: Error) => {
          toast(e.message)
          void recharger()
        })
    },
    [initiaux, modifies, recharger, toast],
  )

  const validerAlerte = useCallback(
    (id?: string) => {
      setAlerteValidee(true)
      if (MODE === 'api' && id)
        repositories.alerts.valider(id).catch((e: Error) => {
          setAlerteValidee(false)
          toast(e.message)
        })
    },
    [toast],
  )

  const arreterScenario = useCallback(() => {
    scenario.current.forEach((t) => window.clearTimeout(t))
    scenario.current = []
  }, [])
  useEffect(() => arreterScenario, [arreterScenario])

  const reinitialiser = useCallback(() => {
    arreterScenario()
    setModifies(undefined)
    setNouveauSos(undefined)
    setAlerteValidee(false)
  }, [arreterScenario])

  const lancerScenario4 = useCallback(() => {
    if (!initiaux?.length) return
    reinitialiser()
    // Le SOS le plus récent n'est pas encore arrivé.
    const [arrivant, ...autres] = initiaux
    setModifies(autres)
    const plusTard = (delai: number, action: () => void) => scenario.current.push(window.setTimeout(action, delai))
    plusTard(ARRIVEE_SOS, () => {
      setModifies((courant) => [arrivant, ...(courant ?? autres)])
      setNouveauSos(cleSos(arrivant))
    })
    plusTard(VALIDATION_ALERTE, () => setAlerteValidee(true))
    plusTard(PRISE_EN_CHARGE, () =>
      setModifies((courant) =>
        courant?.map((s) => (cleSos(s) === cleSos(arrivant) ? { ...s, statut: statutSosSuivant(s.statut) } : s)),
      ),
    )
  }, [initiaux, reinitialiser])

  const etat = useMemo<Etat>(
    () => ({ sos, avancerSos, nouveauSos, alerteValidee, validerAlerte, lancerScenario4, reinitialiser, toast }),
    [sos, avancerSos, nouveauSos, alerteValidee, validerAlerte, lancerScenario4, reinitialiser, toast],
  )

  return (
    <EtatContext.Provider value={etat}>
      {children}
      {message && <Toast message={message} />}
    </EtatContext.Provider>
  )
}

import { useCallback, useEffect, useMemo, useRef, useState, type ReactNode } from 'react'
import { repositories } from '../data'
import { statutSosSuivant, type Sos } from '../data/models'
import { useDonnees } from '../data/useDonnees'
import Toast from '../components/Toast'
import { cleSos, EtatContext, type Etat } from './etat'

// Scénario 4 : délais du prototype s4_dashboard.html.
const ARRIVEE_SOS = 1500
const VALIDATION_ALERTE = 4850
const PRISE_EN_CHARGE = 7200

export default function EtatProvider({ children }: { children: ReactNode }) {
  const initiaux = useDonnees(() => repositories.sos.liste())
  const [modifies, setModifies] = useState<Sos[]>()
  const [nouveauSos, setNouveauSos] = useState<string>()
  const [alerteValidee, setAlerteValidee] = useState(false)
  const [message, setMessage] = useState<string>()
  const minuterie = useRef<number | undefined>(undefined)
  const scenario = useRef<number[]>([])

  const sos = modifies ?? initiaux

  const avancerSos = useCallback(
    (index: number) =>
      setModifies((courant) =>
        (courant ?? initiaux ?? []).map((s, i) => (i === index ? { ...s, statut: statutSosSuivant(s.statut) } : s)),
      ),
    [initiaux],
  )

  const toast = useCallback((texte: string) => {
    setMessage(texte)
    window.clearTimeout(minuterie.current)
    minuterie.current = window.setTimeout(() => setMessage(undefined), 3000)
  }, [])

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
    () => ({
      sos,
      avancerSos,
      nouveauSos,
      alerteValidee,
      validerAlerte: () => setAlerteValidee(true),
      lancerScenario4,
      reinitialiser,
      toast,
    }),
    [sos, avancerSos, nouveauSos, alerteValidee, lancerScenario4, reinitialiser, toast],
  )

  return (
    <EtatContext.Provider value={etat}>
      {children}
      {message && <Toast message={message} />}
    </EtatContext.Provider>
  )
}

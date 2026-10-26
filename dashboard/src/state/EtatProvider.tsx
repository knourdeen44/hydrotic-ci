import { useCallback, useMemo, useRef, useState, type ReactNode } from 'react'
import { repositories } from '../data'
import { statutSosSuivant, type Sos } from '../data/models'
import { useDonnees } from '../data/useDonnees'
import Toast from '../components/Toast'
import { EtatContext, type Etat } from './etat'

export default function EtatProvider({ children }: { children: ReactNode }) {
  const initiaux = useDonnees(() => repositories.sos.liste())
  const [modifies, setModifies] = useState<Sos[]>()
  const [alerteValidee, setAlerteValidee] = useState(false)
  const [message, setMessage] = useState<string>()
  const minuterie = useRef<number | undefined>(undefined)

  const sos = modifies ?? initiaux

  const avancerSos = useCallback(
    (index: number) =>
      setModifies((courant) => {
        const liste = courant ?? initiaux ?? []
        return liste.map((s, i) => (i === index ? { ...s, statut: statutSosSuivant(s.statut) } : s))
      }),
    [initiaux],
  )

  const toast = useCallback((texte: string) => {
    setMessage(texte)
    window.clearTimeout(minuterie.current)
    minuterie.current = window.setTimeout(() => setMessage(undefined), 3000)
  }, [])

  const etat = useMemo<Etat>(
    () => ({ sos, avancerSos, alerteValidee, validerAlerte: () => setAlerteValidee(true), toast }),
    [sos, avancerSos, alerteValidee, toast],
  )

  return (
    <EtatContext.Provider value={etat}>
      {children}
      {message && <Toast message={message} />}
    </EtatContext.Provider>
  )
}

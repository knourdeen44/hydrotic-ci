import { createContext, useContext } from 'react'
import type { Sos } from '../data/models'

/** État local de la démonstration, partagé entre les pages (aucun envoi réel). */
export interface Etat {
  /** SOS victimes avec leur statut courant (un clic sur le statut le fait avancer). */
  sos: Sos[] | undefined
  avancerSos: (index: number) => void
  /** Alerte en attente validée (« ✓ Envoyée »). */
  alerteValidee: boolean
  validerAlerte: () => void
  /** Message bref en bas d'écran. */
  toast: (message: string) => void
}

export const EtatContext = createContext<Etat | null>(null)

export function useEtat(): Etat {
  const etat = useContext(EtatContext)
  if (!etat) throw new Error('useEtat doit être utilisé dans EtatProvider')
  return etat
}

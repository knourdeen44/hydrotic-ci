import { createContext, useContext } from 'react'
import type { Sos } from '../data/models'

/** Identifiant d'un SOS (les fixtures n'en ont pas) : heure + lieu. */
export const cleSos = (s: Sos) => `${s.heure}-${s.lieu}`

/** État local de la démonstration, partagé entre les pages (aucun envoi réel). */
export interface Etat {
  /** SOS victimes avec leur statut courant (un clic sur le statut le fait avancer). */
  sos: Sos[] | undefined
  avancerSos: (index: number) => void
  /** Clé du SOS qui vient d'arriver (animations d'apparition). */
  nouveauSos: string | undefined
  /** Alerte en attente validée (« ✓ Envoyée »). */
  alerteValidee: boolean
  validerAlerte: () => void
  /** Scénario 4 du mode démo (vidéo v4_dashboard). */
  lancerScenario4: () => void
  /** Remet les données de démonstration dans leur état de départ. */
  reinitialiser: () => void
  /** Message bref en bas d'écran. */
  toast: (message: string) => void
}

export const EtatContext = createContext<Etat | null>(null)

export function useEtat(): Etat {
  const etat = useContext(EtatContext)
  if (!etat) throw new Error('useEtat doit être utilisé dans EtatProvider')
  return etat
}

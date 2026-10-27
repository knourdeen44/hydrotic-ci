import { createContext, useContext } from 'react'
import type { Utilisateur } from '../data/models'

/** Agent connecté (mode réel) ; nul en mode démonstration. */
export interface CompteCourant {
  utilisateur: Utilisateur
  seDeconnecter: () => void
}

export const CompteContext = createContext<CompteCourant | null>(null)

export const useCompte = () => useContext(CompteContext)

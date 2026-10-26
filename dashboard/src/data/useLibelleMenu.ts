import { repositories } from '.'
import { useDonnees } from './useDonnees'

/** Titre d'une page = libellé de son entrée de menu (`dashboard.json > menu`). */
export function useLibelleMenu(id: string): string {
  const menu = useDonnees(() => repositories.dashboard.menu())
  return menu?.find((m) => m.id === id)?.libelle ?? ''
}

import type { ReactNode } from 'react'
import ui from './ui.module.css'

/** En-tête de page : titre 22/800, sous-titre, action à droite. */
export default function PageHeader({ titre, sousTitre, action }: { titre: string; sousTitre?: string; action?: ReactNode }) {
  return (
    <header className={ui.hd}>
      <div>
        <h1 className={ui.titre}>{titre}</h1>
        {sousTitre && <p className={ui.sousTitre}>{sousTitre}</p>}
      </div>
      {action}
    </header>
  )
}

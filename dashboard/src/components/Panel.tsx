import type { ReactNode } from 'react'
import ui from './ui.module.css'

/** Panneau blanc à bordure (prototype : `.panel`), titre 14/700 et mention à droite. */
export default function Panel({
  titre,
  aside,
  className,
  children,
}: {
  titre: string
  aside?: string
  className?: string
  children: ReactNode
}) {
  return (
    <section className={`${ui.panel} ${className ?? ''}`} aria-label={titre}>
      <h2 className={ui.panelTitre}>
        {titre}
        {aside && <span className={ui.panelAside}>{aside}</span>}
      </h2>
      {children}
    </section>
  )
}

import type { NiveauRisque } from '../data/models'
import ui from './ui.module.css'

/** Pastille de couleur + mot du niveau (la couleur n'est jamais seule). */
export default function NiveauLabel({ niveau, label }: { niveau: NiveauRisque; label: string }) {
  return (
    <span>
      <span className={ui.dot} style={{ background: `var(--color-risk-${niveau})` }} />
      {label}
    </span>
  )
}

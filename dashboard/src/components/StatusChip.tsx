import type { StatutSos } from '../data/models'
import { fr } from '../i18n/fr'
import ui from './ui.module.css'

const classe: Record<StatutSos, string> = { RECU: ui.recu, EN_ROUTE: ui.enRoute, SECOURU: ui.secouru }

/** Statut d'un SOS : Reçu / En route / Secouru (prototype : `.st.r/.e/.s`). Un clic le fait avancer. */
export default function StatusChip({ statut, onAvancer }: { statut: StatutSos; onAvancer?: () => void }) {
  const label = fr.statutSos[statut]
  if (!onAvancer || statut === 'SECOURU') return <span className={`${ui.st} ${classe[statut]}`}>{label}</span>
  return (
    <button type="button" className={`${ui.st} ${ui.stBouton} ${classe[statut]}`} onClick={onAvancer} title={label}>
      {label}
    </button>
  )
}

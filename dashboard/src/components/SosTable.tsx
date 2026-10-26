import type { Sos } from '../data/models'
import { fr } from '../i18n/fr'
import { cleSos } from '../state/etat'
import styles from './SosTable.module.css'
import StatusChip from './StatusChip'

/** Tableau des SOS victimes (`sos.json > liste`). */
export default function SosTable({
  sos,
  onAvancer,
  nouveau,
}: {
  sos: Sos[]
  onAvancer?: (index: number) => void
  /** Clé du SOS qui vient d'arriver : la ligne entre par la droite, surlignée. */
  nouveau?: string
}) {
  return (
    <table>
      <thead>
        <tr>
          {fr.colonnesSos.map((c) => (
            <th key={c}>{c}</th>
          ))}
        </tr>
      </thead>
      <tbody>
        {sos.map((s, i) => (
          <tr key={cleSos(s)} className={cleSos(s) === nouveau ? styles.nouveau : undefined}>
            <td>{s.heure}</td>
            <td>{s.lieu}</td>
            <td>{s.nbPersonnes}</td>
            <td>{s.details}</td>
            <td>
              <StatusChip statut={s.statut} onAvancer={onAvancer && (() => onAvancer(i))} />
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  )
}

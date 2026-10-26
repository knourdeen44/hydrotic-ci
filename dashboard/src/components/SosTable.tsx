import type { Sos } from '../data/models'
import { fr } from '../i18n/fr'
import StatusChip from './StatusChip'

/** Tableau des SOS victimes (`sos.json > liste`). */
export default function SosTable({ sos, onAvancer }: { sos: Sos[]; onAvancer?: (index: number) => void }) {
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
          <tr key={`${s.heure}-${s.lieu}`}>
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

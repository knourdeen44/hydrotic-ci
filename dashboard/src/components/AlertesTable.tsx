import type { Alerte, NiveauInfo, NiveauRisque, Zone } from '../data/models'
import { fr } from '../i18n/fr'
import NiveauLabel from './NiveauLabel'

/** Tableau des alertes : Niveau · Zone · Titre · Date · Statut · Source (`alerts.json`). */
export default function AlertesTable({
  alertes,
  zones,
  niveaux,
  alerteValidee,
}: {
  alertes: Alerte[]
  zones: Zone[]
  niveaux: Record<NiveauRisque, NiveauInfo>
  /** L'alerte en attente a été validée sur la vue d'ensemble. */
  alerteValidee: boolean
}) {
  const nomZone = (id: string) => zones.find((z) => z.id === id)?.nom ?? id
  return (
    <table>
      <thead>
        <tr>
          {fr.colonnesAlertes.map((c) => (
            <th key={c}>{c}</th>
          ))}
        </tr>
      </thead>
      <tbody>
        {alertes.map((a) => (
          <tr key={a.id}>
            <td>
              <NiveauLabel niveau={a.niveau} label={niveaux[a.niveau].label} />
            </td>
            <td>{nomZone(a.zoneId)}</td>
            <td>{a.titre}</td>
            <td>{a.date}</td>
            <td>{fr.statutAlerte[a.statut === 'EN_ATTENTE' && alerteValidee ? 'ENVOYEE' : a.statut]}</td>
            <td>{a.source}</td>
          </tr>
        ))}
      </tbody>
    </table>
  )
}

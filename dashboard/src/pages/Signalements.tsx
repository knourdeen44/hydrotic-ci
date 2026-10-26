import PageHeader from '../components/PageHeader'
import Panel from '../components/Panel'
import { repositories } from '../data'
import { useDonnees } from '../data/useDonnees'
import { useLibelleMenu } from '../data/useLibelleMenu'
import { fr } from '../i18n/fr'

const charger = async () => {
  const [signalements, zones] = await Promise.all([repositories.reports.signalements(), repositories.zones.zones()])
  return { signalements, zones }
}

/** D4 — Signalements : Rue · Zone · « oui » · « non » · Statut · Il y a (`reports.json`). */
export default function Signalements() {
  const titre = useLibelleMenu('signalements')
  const d = useDonnees(charger)
  if (!d) return null
  const nomZone = (id: string) => d.zones.find((z) => z.id === id)?.nom ?? id
  return (
    <>
      <PageHeader titre={titre} />
      <Panel titre={titre}>
        <table>
          <thead>
            <tr>
              {fr.colonnesSignalements.map((c) => (
                <th key={c}>{c}</th>
              ))}
            </tr>
          </thead>
          <tbody>
            {d.signalements.map((s) => (
              <tr key={s.id}>
                <td>{s.rue}</td>
                <td>{nomZone(s.zoneId)}</td>
                <td>{s.oui}</td>
                <td>{s.non}</td>
                <td>{fr.statutSignalement[s.statut]}</td>
                <td>{s.il}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </Panel>
    </>
  )
}

import AlertesTable from '../components/AlertesTable'
import Bouton from '../components/Bouton'
import PageHeader from '../components/PageHeader'
import Panel from '../components/Panel'
import { repositories } from '../data'
import { useDonnees } from '../data/useDonnees'
import { useLibelleMenu } from '../data/useLibelleMenu'
import { fr } from '../i18n/fr'
import { useEtat } from '../state/etat'

const charger = async () => {
  const [alertes, zones, niveaux] = await Promise.all([
    repositories.alerts.alertes(),
    repositories.zones.zones(),
    repositories.risk.niveaux(),
  ])
  return { alertes, zones, niveaux }
}

/** D6 — Historique & export. */
export default function Historique() {
  const titre = useLibelleMenu('historique')
  const d = useDonnees(charger)
  const { alerteValidee, toast } = useEtat()
  if (!d) return null
  return (
    <>
      <PageHeader titre={titre} action={<Bouton onClick={() => toast(fr.bientot)}>{fr.exporterCsv}</Bouton>} />
      <Panel titre={titre}>
        <AlertesTable alertes={d.alertes} zones={d.zones} niveaux={d.niveaux} alerteValidee={alerteValidee} />
      </Panel>
    </>
  )
}

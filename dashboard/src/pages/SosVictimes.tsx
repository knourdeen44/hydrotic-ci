import PageHeader from '../components/PageHeader'
import Panel from '../components/Panel'
import CarteReelle from '../components/CarteReelle'
import RiskMap from '../components/RiskMap'
import SosTable from '../components/SosTable'
import { repositories } from '../data'
import { MODE } from '../data/mode'
import { useDonnees } from '../data/useDonnees'
import { useLibelleMenu } from '../data/useLibelleMenu'
import { fr } from '../i18n/fr'
import { useEtat } from '../state/etat'
import styles from './pages.module.css'

const charger = async () => {
  const zones = await repositories.zones.zones()
  const risques = await Promise.all(zones.map((z) => repositories.risk.risqueZone(z.id)))
  return zones.map((zone, i) => ({ zone, niveau: risques[i].demain }))
}

/** D3 — SOS victimes : tableau pleine page et carte réduite aux SOS. */
export default function SosVictimes() {
  const titre = useLibelleMenu('sos')
  const zones = useDonnees(charger)
  const { sos, avancerSos } = useEtat()
  if (!zones || !sos) return null
  return (
    <>
      <PageHeader titre={titre} />
      <div className={styles.deuxColonnes}>
        <Panel titre={fr.sosVictimes} aside={fr.tempsReel}>
          <SosTable sos={sos} onAvancer={avancerSos} />
        </Panel>
        <Panel titre={fr.carteSos} aside={fr.schemaIllustratif}>
          {MODE === 'api' ? (
            <CarteReelle zones={zones} sos={sos} legende={false} />
          ) : (
            <RiskMap zones={zones} sos={sos.map((s) => s.positionDashboard)} legende={false} />
          )}
        </Panel>
      </div>
    </>
  )
}

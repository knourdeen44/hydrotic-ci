import PageHeader from '../components/PageHeader'
import Panel from '../components/Panel'
import RainBars from '../components/RainBars'
import { repositories } from '../data'
import type { NiveauInfo, NiveauRisque } from '../data/models'
import { useDonnees } from '../data/useDonnees'
import { useLibelleMenu } from '../data/useLibelleMenu'
import { fr } from '../i18n/fr'
import styles from './pages.module.css'

const charger = async () => {
  const [zones, niveaux, pluie] = await Promise.all([
    repositories.zones.zones(),
    repositories.risk.niveaux(),
    repositories.risk.pluie(),
  ])
  const risques = await Promise.all(zones.map((z) => repositories.risk.risqueZone(z.id)))
  return { zones, niveaux, pluie, risques }
}

/** Carte colorée d'un niveau, toujours avec son mot. */
function Niveau({ jour, niveau, info }: { jour: string; niveau: NiveauRisque; info: NiveauInfo }) {
  return (
    <div className={styles.niveau} style={{ background: `var(--color-risk-${niveau})` }}>
      <div className={styles.niveauJour}>{jour}</div>
      <div className={styles.niveauMot}>{info.label}</div>
    </div>
  )
}

/** D5 — Prévisions : niveau aujourd'hui / demain par zone et pluie (aucune courbe inventée). */
export default function Previsions() {
  const titre = useLibelleMenu('previsions')
  const d = useDonnees(charger)
  if (!d) return null
  return (
    <>
      <PageHeader titre={titre} />
      <div className={styles.grille}>
        {d.zones.map((zone, i) => (
          <Panel key={zone.id} titre={zone.nom} aside={zone.commune}>
            <div className={styles.niveaux}>
              <Niveau jour={fr.aujourdhui} niveau={d.risques[i].aujourdhui} info={d.niveaux[d.risques[i].aujourdhui]} />
              <Niveau jour={fr.demain} niveau={d.risques[i].demain} info={d.niveaux[d.risques[i].demain]} />
            </div>
          </Panel>
        ))}
      </div>
      <Panel titre={fr.pluieTitre}>
        <RainBars jours={d.pluie} />
      </Panel>
    </>
  )
}

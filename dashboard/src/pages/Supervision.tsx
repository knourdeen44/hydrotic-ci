import PageHeader from '../components/PageHeader'
import Panel from '../components/Panel'
import { useLibelleMenu } from '../data/useLibelleMenu'
import { fr } from '../i18n/fr'
import styles from './pages.module.css'

/** D8 — Supervision : aucun service branché en phase 1. */
export default function Supervision() {
  const titre = useLibelleMenu('supervision')
  return (
    <>
      <PageHeader titre={titre} />
      <div className={styles.grille}>
        {fr.supervision.map((service) => (
          <Panel key={service} titre={service}>
            <span className={styles.etat}>{fr.nonConnecte}</span>
          </Panel>
        ))}
      </div>
    </>
  )
}

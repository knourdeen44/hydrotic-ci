import PageHeader from '../components/PageHeader'
import Panel from '../components/Panel'
import { repositories } from '../data'
import { useDonnees } from '../data/useDonnees'
import { useLibelleMenu } from '../data/useLibelleMenu'
import { fr } from '../i18n/fr'
import styles from './pages.module.css'

const charger = () => repositories.dashboard.supervision()

/** D8 — Supervision : état réel de la collecte, du moteur de risque et de l'envoi des alertes. */
export default function Supervision() {
  const titre = useLibelleMenu('supervision')
  const etats = useDonnees(charger)
  if (etats === undefined) return null
  const services = etats ?? fr.supervision.map((service) => ({ service, etat: fr.nonConnecte, ok: false }))
  return (
    <>
      <PageHeader titre={titre} />
      <div className={styles.grille}>
        {services.map((s) => (
          <Panel key={s.service} titre={s.service}>
            <span className={s.ok ? styles.etatOk : styles.etat}>{s.etat}</span>
          </Panel>
        ))}
      </div>
    </>
  )
}

import { useState } from 'react'
import AlertesTable from '../components/AlertesTable'
import PageHeader from '../components/PageHeader'
import Panel from '../components/Panel'
import { repositories } from '../data'
import { NIVEAUX } from '../data/models'
import { useDonnees } from '../data/useDonnees'
import { useLibelleMenu } from '../data/useLibelleMenu'
import { fr } from '../i18n/fr'
import { useEtat } from '../state/etat'
import styles from './pages.module.css'

const charger = async () => {
  const [alertes, zones, niveaux] = await Promise.all([
    repositories.alerts.alertes(),
    repositories.zones.zones(),
    repositories.risk.niveaux(),
  ])
  return { alertes, zones, niveaux }
}

/** D2 — Alertes, filtrables par zone et par niveau (filtre local). */
export default function Alertes() {
  const titre = useLibelleMenu('alertes')
  const d = useDonnees(charger)
  const { alerteValidee } = useEtat()
  const [zone, setZone] = useState('')
  const [niveau, setNiveau] = useState('')
  if (!d) return null
  const alertes = d.alertes.filter((a) => (!zone || a.zoneId === zone) && (!niveau || a.niveau === niveau))
  return (
    <>
      <PageHeader
        titre={titre}
        action={
          <div className={styles.filtres}>
            <select
              className={styles.select}
              aria-label={fr.filtreZone}
              value={zone}
              onChange={(e) => setZone(e.target.value)}
            >
              <option value="">{fr.toutesZones}</option>
              {d.zones.map((z) => (
                <option key={z.id} value={z.id}>
                  {z.nom}
                </option>
              ))}
            </select>
            <select
              className={styles.select}
              aria-label={fr.filtreNiveau}
              value={niveau}
              onChange={(e) => setNiveau(e.target.value)}
            >
              <option value="">{fr.tousNiveaux}</option>
              {NIVEAUX.map((n) => (
                <option key={n} value={n}>
                  {d.niveaux[n].label}
                </option>
              ))}
            </select>
          </div>
        }
      />
      <Panel titre={titre}>
        <AlertesTable alertes={alertes} zones={d.zones} niveaux={d.niveaux} alerteValidee={alerteValidee} />
      </Panel>
    </>
  )
}

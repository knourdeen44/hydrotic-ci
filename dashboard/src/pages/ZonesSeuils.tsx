import NiveauLabel from '../components/NiveauLabel'
import PageHeader from '../components/PageHeader'
import Panel from '../components/Panel'
import { repositories } from '../data'
import { useDonnees } from '../data/useDonnees'
import { useLibelleMenu } from '../data/useLibelleMenu'
import { fr } from '../i18n/fr'
import styles from './pages.module.css'

const charger = async () => {
  const [zones, niveaux] = await Promise.all([repositories.zones.zones(), repositories.risk.niveaux()])
  return { zones, niveaux }
}

/** D7 — Zones et seuils (lecture seule ; seuils de départ du cahier des charges, section 11.1). */
export default function ZonesSeuils() {
  const titre = useLibelleMenu('zones')
  const d = useDonnees(charger)
  if (!d) return null
  return (
    <>
      <PageHeader titre={titre} />
      <div className={styles.grille}>
        {d.zones.map((zone) => (
          <Panel key={zone.id} titre={zone.nom} aside={zone.commune}>
            <p className={styles.texte}>{zone.profil}</p>
            <ul className={styles.liste} aria-label={fr.zonesEtSousZones}>
              {zone.sousZones.map((s) => (
                <li key={s} className={styles.puce}>
                  {s}
                </li>
              ))}
            </ul>
          </Panel>
        ))}
        <Panel titre={fr.seuilsTitre}>
          <table>
            <thead>
              <tr>
                {fr.colonnesSeuils.map((c) => (
                  <th key={c}>{c}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {fr.seuils.map(([niveau, plage]) => (
                <tr key={niveau}>
                  <td>
                    <NiveauLabel niveau={niveau} label={d.niveaux[niveau].label} />
                  </td>
                  <td>{plage}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </Panel>
      </div>
    </>
  )
}

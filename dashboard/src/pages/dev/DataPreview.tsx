import { useEffect, useState } from 'react'
import { repositories } from '../../data'
import styles from './ThemePreview.module.css'

// Page de développement (étape 3) : vérifie que chaque dépôt « mock » lit ses fixtures.
// Remplacée par D1 à l'étape 6.

type Ligne = [string, string]

async function chargerResume(): Promise<Ligne[]> {
  const r = repositories
  const [zones, niveaux, risque, pluie, consignes, alertes, signalements, sosCourant, sos, citoyen, agent, kpis, menu] =
    await Promise.all([
      r.zones.zones(),
      r.risk.niveaux(),
      r.risk.risqueZone('treichville'),
      r.risk.pluie(),
      r.risk.consignes('orange'),
      r.alerts.alertes(),
      r.reports.signalements(),
      r.sos.sosCourant(),
      r.sos.liste(),
      r.users.citoyen(),
      r.users.agent(),
      r.dashboard.kpis(),
      r.dashboard.menu(),
    ])
  return [
    ['Zones', zones.map((z) => `${z.nom} (${z.commune})`).join(' · ')],
    ['Niveaux', Object.values(niveaux).map((n) => n.label).join(' · ')],
    ['Risque Treichville', `aujourd'hui ${risque.aujourdhui} · demain ${risque.demain}`],
    ['Pluie (mm)', pluie.map((p) => `${p.label} ${p.mm}${p.prevision ? '*' : ''}`).join(' · ')],
    ['Consignes orange', `${consignes.length} consignes`],
    ['Alertes', alertes.map((a) => `${a.id} ${a.niveau} ${a.statut}`).join(' · ')],
    ['Signalements', signalements.map((s) => `${s.rue} (${s.statut}, ${s.oui} oui)`).join(' · ')],
    ['SOS courant', sosCourant.timeline.map((e) => e.etape).join(' → ')],
    ['SOS victimes', sos.map((s) => `${s.heure} ${s.statut}`).join(' · ')],
    ['Utilisateurs', `${citoyen.nom} (${citoyen.role}, ${citoyen.canauxPreferes.join('+')}) · ${agent.nom} (${agent.role})`],
    ['Tableau de bord', `${kpis.length} KPI · ${menu.length} entrées de menu`],
  ]
}

export default function DataPreview() {
  const [lignes, setLignes] = useState<Ligne[]>([])
  const [erreur, setErreur] = useState<string>()

  useEffect(() => {
    chargerResume().then(setLignes, (e: Error) => setErreur(e.message))
  }, [])

  return (
    <section className={styles.panel}>
      <h2 className={styles.panelTitle}>Données fictives (dépôts « mock »)</h2>
      {erreur && <p>Erreur : {erreur}</p>}
      <table className={styles.table}>
        <tbody>
          {lignes.map(([cle, valeur]) => (
            <tr key={cle}>
              <th>{cle}</th>
              <td>{valeur}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </section>
  )
}

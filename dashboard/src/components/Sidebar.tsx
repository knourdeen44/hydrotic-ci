import { NavLink } from 'react-router-dom'
import logo from '../assets/logo_hydrotic_icon.png'
import { repositories } from '../data'
import { useDonnees } from '../data/useDonnees'
import { fr } from '../i18n/fr'
import { useEtat } from '../state/etat'
import styles from './Sidebar.module.css'

/** Chemin de chaque entrée du menu (`dashboard.json > menu`). */
const cheminMenu = (id: string) => (id === 'overview' ? '/' : `/${id}`)

/** Barre latérale : logo, menu avec badges, mention « données fictives » en pied. */
export default function Sidebar() {
  const menu = useDonnees(() => repositories.dashboard.menu())
  const { alerteValidee, sos } = useEtat()
  return (
    <nav className={styles.side} aria-label="Menu principal">
      <div className={styles.brand}>
        <img src={logo} alt="" className={styles.logo} />
        <div>
          <b className={styles.nom}>{fr.nomApp}</b>
          <small className={styles.espace}>{fr.espaceAutorites}</small>
        </div>
      </div>
      {menu?.map((entree) => {
        // L'alerte en attente validée ne compte plus dans le badge « Alertes ».
        let badge = entree.id === 'alertes' && alerteValidee ? undefined : entree.badge
        // Badge « SOS victimes » : nombre de SOS reçus (suit le mode démo).
        if (entree.id === 'sos' && sos) badge = sos.length
        return (
          <NavLink
            key={entree.id}
            to={cheminMenu(entree.id)}
            end
            className={({ isActive }) => `${styles.it} ${isActive ? styles.on : ''}`}
          >
            {entree.libelle}
            {badge !== undefined && <span className={styles.badge}>{badge}</span>}
          </NavLink>
        )
      })}
      <p className={styles.demo}>{fr.modeDemo}</p>
    </nav>
  )
}

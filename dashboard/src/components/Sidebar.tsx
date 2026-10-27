import { NavLink } from 'react-router-dom'
import logo from '../assets/logo_hydrotic_icon.png'
import { repositories } from '../data'
import { MODE } from '../data/mode'
import { useDonnees } from '../data/useDonnees'
import { fr } from '../i18n/fr'
import { useCompte } from '../state/compte'
import { useEtat } from '../state/etat'
import styles from './Sidebar.module.css'

/** Chemin de chaque entrée du menu (`dashboard.json > menu`). */
const cheminMenu = (id: string) => (id === 'overview' ? '/' : `/${id}`)

/** Barre latérale : logo, menu avec badges, mention « données fictives » en pied. */
export default function Sidebar() {
  const menu = useDonnees(() => repositories.dashboard.menu())
  const { alerteValidee, sos } = useEtat()
  const compte = useCompte()
  const entrees = [
    ...(menu ?? []),
    // Gestion des rôles : administrateurs seulement (mode réel).
    ...(compte?.utilisateur.role === 'ADMIN' ? [{ id: 'comptes', libelle: fr.comptes, badge: undefined }] : []),
  ]
  return (
    <nav className={styles.side} aria-label="Menu principal">
      <div className={styles.brand}>
        <img src={logo} alt="" className={styles.logo} />
        <div>
          <b className={styles.nom}>{fr.nomApp}</b>
          <small className={styles.espace}>{fr.espaceAutorites}</small>
        </div>
      </div>
      {entrees.map((entree) => {
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
      {compte && (
        <div className={styles.compte}>
          <b>{compte.utilisateur.nom}</b>
          <button type="button" className={styles.deconnexion} onClick={compte.seDeconnecter}>
            {fr.seDeconnecter}
          </button>
        </div>
      )}
      <p className={compte ? styles.reel : styles.demo}>{MODE === 'api' ? fr.modeDonneesReelles : fr.modeDemo}</p>
    </nav>
  )
}

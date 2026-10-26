import { useEffect, useRef, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { fr } from '../i18n/fr'
import { useEtat } from '../state/etat'
import styles from './DemoMenu.module.css'

/** Scénarios 1 à 3 : application mobile (publiée à côté du tableau de bord, dans `../app/`). */
const SCENARIOS_MOBILE: [string, string][] = [
  [fr.scenario1, '../app/#/?demo=alerte'],
  [fr.scenario2, '../app/#/carte?demo=confirmation'],
  [fr.scenario3, '../app/#/sos?demo=sos'],
]

/** Menu caché du mode démo : Ctrl + D (ou ⌘ + D). */
export default function DemoMenu() {
  const [ouvert, setOuvert] = useState(false)
  const { lancerScenario4, reinitialiser } = useEtat()
  const navigate = useNavigate()
  const premier = useRef<HTMLAnchorElement>(null)

  useEffect(() => {
    const clavier = (e: KeyboardEvent) => {
      if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'd') {
        e.preventDefault()
        setOuvert((o) => !o)
      } else if (e.key === 'Escape') {
        setOuvert(false)
      }
    }
    window.addEventListener('keydown', clavier)
    return () => window.removeEventListener('keydown', clavier)
  }, [])

  useEffect(() => {
    if (ouvert) premier.current?.focus()
  }, [ouvert])

  if (!ouvert) return null
  const fermerPuis = (action: () => void) => () => {
    setOuvert(false)
    action()
  }
  return (
    <div className={styles.fond} onClick={() => setOuvert(false)}>
      <div
        className={styles.menu}
        role="dialog"
        aria-modal="true"
        aria-labelledby="titre-demo"
        onClick={(e) => e.stopPropagation()}
      >
        <h2 id="titre-demo" className={styles.titre}>
          {fr.modeDemoTitre}
        </h2>
        {SCENARIOS_MOBILE.map(([label, lien], i) => (
          <a
            key={label}
            ref={i === 0 ? premier : undefined}
            className={styles.entree}
            href={lien}
            target="_blank"
            rel="noopener"
            onClick={() => setOuvert(false)}
          >
            {label}
            <span className={styles.note}>{fr.applicationMobile}</span>
          </a>
        ))}
        <button
          type="button"
          className={styles.entree}
          onClick={fermerPuis(() => {
            navigate('/')
            lancerScenario4()
          })}
        >
          {fr.scenario4}
        </button>
        <button
          type="button"
          className={styles.entree}
          onClick={fermerPuis(() => {
            reinitialiser()
            navigate('/')
          })}
        >
          {fr.reinitialiser}
        </button>
      </div>
    </div>
  )
}

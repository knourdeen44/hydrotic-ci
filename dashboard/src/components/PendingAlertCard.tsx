import type { Alerte } from '../data/models'
import { fr, NBSP } from '../i18n/fr'
import styles from './PendingAlertCard.module.css'

/** Texte coupé à un mot, au plus [max] caractères, suivi de « … ». */
function extrait(texte: string, max = 50): string {
  if (texte.length <= max) return texte
  const coupe = texte.slice(0, max)
  return `${coupe.slice(0, coupe.lastIndexOf(' ')).trimEnd()}…`
}

/** Alerte en attente de validation par un agent (prototype : `.pend`). */
export default function PendingAlertCard({
  alerte,
  zone,
  lieu,
  message,
  validee,
  onValider,
  onModifier,
  onAnnuler,
}: {
  alerte: Alerte
  zone: string
  /** Lieu des signalements confirmés (« rue Ministre »). */
  lieu: string
  /** Message qui sera envoyé (modèle `alerts.json > modeles`). */
  message: string
  validee: boolean
  onValider: () => void
  onModifier: () => void
  onAnnuler: () => void
}) {
  return (
    <div className={styles.pend}>
      <b className={styles.niveau}>
        {alerte.niveau.toUpperCase()} · {zone}
      </b>
      {' — '}
      {fr.probabilite(alerte.probabilite ?? 0)}, {fr.signalementsConfirmes(alerte.signalementsConfirmes ?? 0, lieu)}.
      <br />
      {fr.message}«{NBSP}
      {extrait(message)}
      {NBSP}»
      <div className={styles.actions}>
        {validee ? (
          <span className={`${styles.action} ${styles.envoyee}`} role="status">
            {fr.envoyee}
          </span>
        ) : (
          <>
            <button type="button" className={`${styles.action} ${styles.ok}`} onClick={onValider}>
              {fr.validerEnvoyer}
            </button>
            <button type="button" className={styles.action} onClick={onModifier}>
              {fr.modifier}
            </button>
            <button type="button" className={styles.action} onClick={onAnnuler}>
              {fr.annuler}
            </button>
          </>
        )}
      </div>
    </div>
  )
}

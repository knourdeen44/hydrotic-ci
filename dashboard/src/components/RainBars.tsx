import type { PluieJour } from '../data/models'
import styles from './RainBars.module.css'

/** Barres de pluie (prototype mobile `.bars`), en grand : prévisions hachurées. */
export default function RainBars({ jours, hauteur = 220 }: { jours: PluieJour[]; hauteur?: number }) {
  const max = Math.max(...jours.map((j) => j.mm), 0)
  return (
    <figure className={styles.figure}>
      <div className={styles.bars} style={{ height: hauteur }}>
        {jours.map((j) => (
          <div key={j.label} className={styles.col} title={`${j.label} · ${j.mm} mm`}>
            <span className={styles.mm}>{j.mm}</span>
            <div
              className={`${styles.bar} ${j.prevision ? styles.prevision : ''}`}
              // La barre la plus haute occupe 92 % de la hauteur (valeurs du prototype).
              style={{ height: `${max ? (j.mm / max) * 92 : 0}%` }}
            />
          </div>
        ))}
      </div>
      <div className={styles.labels}>
        {jours.map((j) => (
          <span key={j.label}>{j.label}</span>
        ))}
      </div>
    </figure>
  )
}

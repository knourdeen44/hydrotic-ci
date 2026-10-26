import logo from '../../assets/logo_hydrotic_icon.png'
import styles from './ThemePreview.module.css'

// Page de développement (étape 2) : aperçu des variables générées dans tokens.css.
// Remplacée par D1 à l'étape 6.

const brand = ['slate', 'slate-dark', 'slate-light', 'slate-xlight', 'gray', 'gray-light', 'deep']

// Couleur de risque toujours accompagnée de son mot.
const risk = [
  ['Normal', 'vert'],
  ['Vigilance', 'jaune'],
  ['Risque élevé', 'orange'],
  ['Danger', 'rouge'],
]

export default function ThemePreview() {
  return (
    <main className={styles.page}>
      <header className={styles.header}>
        <img src={logo} alt="" width={34} height={34} />
        <h1 className={styles.title}>Hydrotic CI — aperçu du thème</h1>
      </header>

      <section className={styles.panel}>
        <h2 className={styles.panelTitle}>Couleurs de marque</h2>
        <div className={styles.swatches}>
          {brand.map((name) => (
            <div key={name} className={styles.swatch}>
              <div className={styles.chip} style={{ background: `var(--color-${name})` }} />
              --color-{name}
            </div>
          ))}
        </div>
      </section>

      <section className={styles.panel}>
        <h2 className={styles.panelTitle}>Niveaux de risque</h2>
        <div className={styles.risk}>
          {risk.map(([label, key]) => (
            <div key={key} className={styles.riskCard} style={{ background: `var(--color-risk-${key})` }}>
              {label}
            </div>
          ))}
        </div>
      </section>

      <section className={styles.panel}>
        <h2 className={styles.panelTitle}>Typographie (Inter)</h2>
        <p className={styles.kpi}>kpiValue 28/800</p>
        <p className={styles.title}>pageTitle 22/800</p>
        <p className={styles.panelTitle}>panelTitle 14/700</p>
        <p>body 12/400</p>
      </section>
    </main>
  )
}

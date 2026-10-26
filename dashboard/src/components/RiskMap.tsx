import type { NiveauRisque, PointSvg, Zone } from '../data/models'
import { fr } from '../i18n/fr'
import styles from './RiskMap.module.css'
import ui from './ui.module.css'

// Fond de la carte schématique (prototype s4_dashboard.html, viewBox 0 0 760 700).
// Purement décoratif : remplacé par une vraie carte (Leaflet + OpenStreetMap) en phase 2.
const EAU = 'M0 520 C150 490 260 550 380 520 S620 470 760 510 L760 700 L0 700Z'
const ROUTES: [string, number][] = [
  ['M0 260 L760 290', 12],
  ['M300 0 L340 700', 12],
  ['M690 0 L660 700', 9],
]

/** Remplissage et contour d'une zone selon son niveau (variables de tokens.css). */
function couleursZone(niveau: NiveauRisque) {
  if (niveau === 'orange' || niveau === 'rouge') {
    return { fill: `var(--color-overlay-zone-${niveau}-fill)`, stroke: `var(--color-overlay-zone-${niveau}-stroke)` }
  }
  const couleur = `var(--color-risk-${niveau})`
  return { fill: `color-mix(in srgb, ${couleur} 22%, transparent)`, stroke: couleur }
}

export interface ZoneCarte {
  zone: Zone
  niveau: NiveauRisque
}

/** Carte des risques (SVG schématique) : zones, victimes (SOS) et signalements confirmés. */
export default function RiskMap({
  zones,
  sos,
  signalements = [],
  legende = true,
}: {
  zones: ZoneCarte[]
  sos: PointSvg[]
  signalements?: PointSvg[]
  legende?: boolean
}) {
  return (
    <div className={styles.map}>
      <svg
        width="100%"
        height="100%"
        viewBox="0 0 760 700"
        preserveAspectRatio="xMidYMid meet"
        role="img"
        aria-label={fr.carteTitre}
      >
        <path d={EAU} style={{ fill: 'var(--color-map-water)' }} />
        {ROUTES.map(([d, largeur]) => (
          <path key={d} d={d} strokeWidth={largeur} style={{ stroke: 'var(--color-white)' }} />
        ))}
        {zones.map(({ zone, niveau }) => {
          const { fill, stroke } = couleursZone(niveau)
          const etiquette = zone.etiquetteDashboard
          return (
            <g key={zone.id}>
              <path d={zone.svgDashboard} strokeWidth={2} style={{ fill, stroke }} />
              {etiquette && (
                <text x={etiquette.x} y={etiquette.y} className={styles.etiquette}>
                  {zone.commune === zone.nom ? zone.nom : `${zone.commune} — ${zone.nom}`}
                </text>
              )}
            </g>
          )
        })}
        {sos.map((p) => (
          <circle key={`s-${p.x}-${p.y}`} cx={p.x} cy={p.y} r={11} strokeWidth={3} className={styles.sos} />
        ))}
        {signalements.map((p) => (
          <rect
            key={`r-${p.x}-${p.y}`}
            x={p.x}
            y={p.y}
            width={14}
            height={14}
            rx={3}
            strokeWidth={2}
            className={styles.signalement}
          />
        ))}
      </svg>
      {legende && (
        <div className={styles.legend}>
          <span className={`${ui.dot} ${styles.dotSos}`} />
          {fr.legendeVictime}
          {'  '}
          <span className={`${ui.dot} ${styles.dotSignalement}`} />
          {fr.legendeSignalement}
          <br />
          <span className={`${ui.dot} ${styles.dotRouge}`} />
          {fr.legendeZoneRouge}
          {'  '}
          <span className={`${ui.dot} ${styles.dotOrange}`} />
          {fr.legendeZoneOrange}
        </div>
      )}
    </div>
  )
}

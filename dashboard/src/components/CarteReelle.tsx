import 'leaflet/dist/leaflet.css'
import L from 'leaflet'
import type { Feature } from 'geojson'
import { useMemo } from 'react'
import { CircleMarker, GeoJSON, MapContainer, Marker, TileLayer, Tooltip } from 'react-leaflet'
import type { NiveauRisque, Signalement, Sos } from '../data/models'
import { fr } from '../i18n/fr'
import type { ZoneCarte } from './RiskMap'
import styles from './RiskMap.module.css'
import ui from './ui.module.css'

// Carte réelle (mode API) : fond OpenStreetMap, contours OSM des quartiers, SOS et signalements.
// Les couleurs viennent des variables CSS générées depuis design/tokens.json.
const css = (nom: string) => getComputedStyle(document.documentElement).getPropertyValue(nom).trim()
const TUILES = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
const ABIDJAN: [number, number] = [5.33, -3.98]

interface Proprietes {
  niveau: NiveauRisque
  nom: string
}

export default function CarteReelle({
  zones,
  sos,
  signalements = [],
  legende = true,
}: {
  zones: ZoneCarte[]
  sos: Sos[]
  signalements?: Signalement[]
  legende?: boolean
}) {
  const contours = useMemo(
    () =>
      zones
        .filter((z) => z.zone.contour)
        .map(
          (z): Feature => ({
            type: 'Feature',
            geometry: z.zone.contour!,
            properties: { niveau: z.niveau, nom: z.zone.nom } satisfies Proprietes,
          }),
        ),
    [zones],
  )
  const limites = useMemo(() => {
    const cadres = contours.map((c) => L.geoJSON(c).getBounds())
    return cadres.length ? cadres.reduce((a, b) => a.extend(b)) : undefined
  }, [contours])
  const icone = useMemo(() => L.divIcon({ className: styles.carre, iconSize: [14, 14] }), [])

  return (
    <div className={styles.map}>
      <MapContainer
        bounds={limites}
        center={limites ? undefined : ABIDJAN}
        zoom={limites ? undefined : 12}
        boundsOptions={{ padding: [24, 24] }}
        className={styles.leaflet}
        aria-label={fr.carteReelleTitre}
      >
        <TileLayer url={TUILES} attribution={fr.attributionOsm} />
        {contours.map((c) => {
          const { niveau, nom } = c.properties as Proprietes
          const couleur = css(`--color-risk-${niveau}`)
          return (
            <GeoJSON
              key={`${nom}-${niveau}`}
              data={c}
              style={{ color: couleur, weight: 2, fillColor: couleur, fillOpacity: 0.22 }}
            >
              <Tooltip sticky>{nom}</Tooltip>
            </GeoJSON>
          )
        })}
        {signalements
          .filter((s) => s.geo)
          .map((s) => (
            <Marker key={s.id} position={[s.geo!.lat, s.geo!.lon]} icon={icone}>
              <Tooltip>{`${s.rue} · ${s.oui} « oui » · ${s.non} « non »`}</Tooltip>
            </Marker>
          ))}
        {sos
          .filter((s) => s.geo)
          .map((s) => (
            <CircleMarker
              key={s.id ?? s.heure}
              center={[s.geo!.lat, s.geo!.lon]}
              radius={9}
              pathOptions={{ color: css('--color-white'), weight: 3, fillColor: css('--color-risk-rouge'), fillOpacity: 1 }}
            >
              <Tooltip>{`${s.heure} · ${s.lieu} · ${fr.statutSos[s.statut]}`}</Tooltip>
            </CircleMarker>
          ))}
      </MapContainer>
      {legende && (
        <div className={`${styles.legend} ${styles.legendeLeaflet}`}>
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

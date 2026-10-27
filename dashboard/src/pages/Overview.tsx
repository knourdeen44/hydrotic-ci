import Bouton from '../components/Bouton'
import KpiCard from '../components/KpiCard'
import PageHeader from '../components/PageHeader'
import Panel from '../components/Panel'
import PendingAlertCard from '../components/PendingAlertCard'
import CarteReelle from '../components/CarteReelle'
import RiskMap from '../components/RiskMap'
import SosTable from '../components/SosTable'
import { repositories } from '../data'
import { MODE } from '../data/mode'
import { useDonnees } from '../data/useDonnees'
import { fr } from '../i18n/fr'
import { cleSos, useEtat } from '../state/etat'
import styles from './Overview.module.css'

/** Données de la vue d'ensemble : en-tête, KPI, carte (niveaux de demain), alerte en attente. */
async function charger() {
  const r = repositories
  const [entete, kpis, zones, signalementsCarte, alertes, modeles, signalements] = await Promise.all([
    r.dashboard.entete(),
    r.dashboard.kpis(),
    r.zones.zones(),
    r.dashboard.signalementsCarte(),
    r.alerts.alertes(),
    r.alerts.modeles(),
    MODE === 'api' ? r.reports.signalements() : Promise.resolve([]),
  ])
  const risques = await Promise.all(zones.map((z) => r.risk.risqueZone(z.id)))
  const enAttente = alertes.find((a) => a.statut === 'EN_ATTENTE')
  const zoneAttente = zones.find((z) => z.id === enAttente?.zoneId)
  return {
    entete,
    kpis,
    signalementsCarte,
    signalements,
    zones: zones.map((zone, i) => ({ zone, niveau: risques[i].demain })),
    attente: enAttente &&
      zoneAttente && {
        alerte: enAttente,
        zone: zoneAttente.nom,
        // Lieu des signalements : première sous-zone (« Rue Ministre » → « rue Ministre »).
        lieu: zoneAttente.sousZones[0].replace(/^./, (c) => c.toLowerCase()),
        message: (modeles[enAttente.niveau] ?? enAttente.corps).replace('[quartier]', zoneAttente.nom),
      },
  }
}

/** D1 — Vue d'ensemble. */
export default function Overview() {
  const d = useDonnees(charger)
  const { sos, avancerSos, nouveauSos, alerteValidee, validerAlerte, toast } = useEtat()
  if (!d) return null
  // Indicateur « SOS actifs » recalculé depuis la liste (mode démo : suit les clics et le scénario 4).
  const kpis = d.kpis.map((kpi) =>
    MODE === 'demo' && kpi.libelle === fr.kpiSosActifs && sos
      ? {
          ...kpi,
          valeur: String(sos.length),
          detail: kpi.detail.replace(/^\d+/, String(sos.filter((s) => s.statut === 'RECU').length)),
        }
      : kpi,
  )
  const arrivant = sos?.find((s) => cleSos(s) === nouveauSos)
  const bientot = () => toast(fr.bientot)
  return (
    <>
      <PageHeader
        titre={d.entete.titre}
        sousTitre={d.entete.sousTitre}
        action={<Bouton onClick={bientot}>{fr.alerteManuelle}</Bouton>}
      />
      <div className={styles.kpis}>
        {kpis.map((kpi) => (
          <KpiCard key={kpi.libelle} kpi={kpi} />
        ))}
      </div>
      <div className={styles.grid}>
        <Panel titre={fr.carteTitre} aside={fr.schemaIllustratif}>
          {MODE === 'api' ? (
            <CarteReelle zones={d.zones} sos={sos ?? []} signalements={d.signalements} />
          ) : (
            <RiskMap
              zones={d.zones}
              sos={(sos ?? []).map((s) => s.positionDashboard)}
              nouveau={arrivant?.positionDashboard}
              signalements={d.signalementsCarte}
            />
          )}
        </Panel>
        <div className={styles.right}>
          {d.attente && (
            <Panel titre={fr.alerteEnAttente}>
              <PendingAlertCard
                {...d.attente}
                validee={alerteValidee}
                onValider={() => validerAlerte(d.attente?.alerte.id)}
                onModifier={bientot}
                onAnnuler={bientot}
              />
            </Panel>
          )}
          <Panel titre={fr.sosVictimes} aside={fr.tempsReel} className={styles.fill}>
            {sos && <SosTable sos={sos} onAvancer={avancerSos} nouveau={nouveauSos} />}
          </Panel>
        </div>
      </div>
    </>
  )
}

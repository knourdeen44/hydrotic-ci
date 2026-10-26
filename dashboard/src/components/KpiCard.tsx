import type { Kpi } from '../data/models'
import ui from './ui.module.css'

/** Indicateur clé (prototype : `.kpi`). */
export default function KpiCard({ kpi }: { kpi: Kpi }) {
  return (
    <div className={ui.kpi}>
      <div className={ui.kpiLibelle}>{kpi.libelle}</div>
      <div className={ui.kpiValeur}>{kpi.valeur}</div>
      <div className={ui.kpiDetail}>{kpi.detail}</div>
    </div>
  )
}

import type {
  Alerte,
  EnteteDashboard,
  EntreeMenu,
  Kpi,
  NiveauInfo,
  NiveauRisque,
  PluieJour,
  PointSvg,
  RisqueZone,
  Signalement,
  Sos,
  SosCourant,
  Utilisateur,
  Zone,
} from './models'

// Contrats d'accès aux données. Phase 1 : implémentations « mock » (fixtures JSON).
// Phase 2 : implémentations API, branchées dans data/index.ts sans toucher aux pages.

export interface ZoneRepository {
  zones(): Promise<Zone[]>
  zone(id: string): Promise<Zone>
}

export interface RiskRepository {
  niveaux(): Promise<Record<NiveauRisque, NiveauInfo>>
  risqueZone(zoneId: string): Promise<RisqueZone>
  pluie(): Promise<PluieJour[]>
  /** Consignes à suivre pour un niveau (liste vide si aucune). */
  consignes(niveau: NiveauRisque): Promise<string[]>
}

export interface AlertRepository {
  alertes(): Promise<Alerte[]>
  alerte(id: string): Promise<Alerte>
  /** Modèles de messages (clé : orange, rouge, confirmation, sosRecu, finAlerte). */
  modeles(): Promise<Record<string, string>>
}

export interface ReportRepository {
  signalements(): Promise<Signalement[]>
  positionUtilisateur(): Promise<PointSvg>
  ajouter(signalement: Signalement): Promise<void>
}

export interface SosRepository {
  sosCourant(): Promise<SosCourant>
  liste(): Promise<Sos[]>
}

export interface UserRepository {
  citoyen(): Promise<Utilisateur>
  agent(): Promise<Utilisateur>
}

export interface DashboardRepository {
  entete(): Promise<EnteteDashboard>
  kpis(): Promise<Kpi[]>
  menu(): Promise<EntreeMenu[]>
  /** Signalements affichés sur la carte du tableau de bord. */
  signalementsCarte(): Promise<PointSvg[]>
}

export interface Repositories {
  zones: ZoneRepository
  risk: RiskRepository
  alerts: AlertRepository
  reports: ReportRepository
  sos: SosRepository
  users: UserRepository
  dashboard: DashboardRepository
}

// Modèles de données (noms repris du diagramme docs/uml_classes.png).

export const NIVEAUX = ['vert', 'jaune', 'orange', 'rouge'] as const
export type NiveauRisque = (typeof NIVEAUX)[number]

/** Point dans le repère SVG d'une carte schématique (pas une coordonnée géographique). */
export interface PointSvg {
  x: number
  y: number
}

/** Textes associés à un niveau (risk.json > niveaux). */
export interface NiveauInfo {
  label: string
  titre: string
  message: string
}

export interface Zone {
  id: string
  nom: string
  commune: string
  profil: string
  sousZones: string[]
  /** Contour schématique (chemin SVG) pour la carte mobile. */
  svgMobile: string
  /** Contour schématique (chemin SVG) pour la carte du tableau de bord. */
  svgDashboard: string
}

/** Prévision de risque d'une zone (UML : Prediction). */
export interface RisqueZone {
  zoneId: string
  aujourdhui: NiveauRisque
  demain: NiveauRisque
  signalementsConfirmes: number
  /** Ancienneté de la mise à jour, déjà formatée (« 2 min »). */
  majIl: string
}

/** Pluie d'un jour (UML : Observation). */
export interface PluieJour {
  label: string
  mm: number
  /** Vrai pour les jours prévus (barres hachurées). */
  prevision: boolean
}

export const STATUTS_ALERTE = ['ENVOYEE', 'EN_ATTENTE'] as const
export type StatutAlerte = (typeof STATUTS_ALERTE)[number]

export interface Alerte {
  id: string
  zoneId: string
  niveau: NiveauRisque
  titre: string
  corps: string
  statut: StatutAlerte
  /** Date déjà formatée pour l'affichage. */
  date: string
  source: string
  probabilite?: number
  signalementsConfirmes?: number
}

export const STATUTS_SIGNALEMENT = ['A_CONFIRMER', 'CONFIRME'] as const
export type StatutSignalement = (typeof STATUTS_SIGNALEMENT)[number]

export interface Signalement {
  id: string
  zoneId: string
  rue: string
  statut: StatutSignalement
  oui: number
  non: number
  /** Ancienneté déjà formatée (« 38 min »). */
  il: string
  /** Position sur la carte schématique mobile. */
  position: PointSvg
  distanceUtilisateur?: string
  hauteurEau?: string
  apresOui?: { statut: StatutSignalement; oui: number; non: number }
}

export const STATUTS_SOS = ['RECU', 'EN_ROUTE', 'SECOURU'] as const
export type StatutSos = (typeof STATUTS_SOS)[number]

/** Statut suivant (Reçu → En route → Secouru). */
export function statutSosSuivant(statut: StatutSos): StatutSos {
  const i = STATUTS_SOS.indexOf(statut)
  return STATUTS_SOS[Math.min(i + 1, STATUTS_SOS.length - 1)]
}

/** SOS reçu par les autorités (UML : SOS). */
export interface Sos {
  heure: string
  lieu: string
  nbPersonnes: number
  details: string
  statut: StatutSos
  /** Position sur la carte schématique du tableau de bord. */
  positionDashboard: PointSvg
}

export interface EtapeSos {
  etape: string
  detail: string
  fait: boolean
}

/** SOS envoyé par l'utilisateur (sos.json > sosCourant). */
export interface SosCourant {
  lieu: string
  precisionM: number
  nbPersonnes: number
  blesses: boolean
  hauteurEau: string
  enfantsOuAges: boolean
  timeline: EtapeSos[]
}

export const ROLES = ['CITOYEN', 'AGENT', 'ADMIN'] as const
export type Role = (typeof ROLES)[number]

export const CANAUX = ['push', 'email'] as const
export type Canal = (typeof CANAUX)[number]

export interface Utilisateur {
  id: string
  /** Citoyen : prénom ; agent : nom complet. */
  nom: string
  role: Role
  quartierPrincipal?: string
  zonesSuivies: string[]
  canauxPreferes: Canal[]
  scoreFiabilite?: number
  service?: string
}

// Données propres au tableau de bord (dashboard.json).

export interface EnteteDashboard {
  titre: string
  sousTitre: string
}

export interface Kpi {
  libelle: string
  valeur: string
  detail: string
}

export interface EntreeMenu {
  id: string
  libelle: string
  badge?: number
}

import {
  CANAUX,
  NIVEAUX,
  ROLES,
  STATUTS_ALERTE,
  STATUTS_SIGNALEMENT,
  STATUTS_SOS,
  type Alerte,
  type Signalement,
  type Sos,
  type SosCourant,
  type Utilisateur,
} from '../models'

// Conversion des fixtures JSON vers les modèles, avec contrôle des valeurs énumérées.

/** Espace insécable. */
export const NBSP = '\u00A0'

/** Typographie française : espace insécable avant « : ? ! % » et à l'intérieur des guillemets. */
export function typographieFr(text: string): string {
  return text.replace(/ ([:?!%»])/g, `${NBSP}$1`).replace(/« /g, `«${NBSP}`)
}

/** Applique [typographieFr] à toutes les chaînes d'une fixture. */
export function typographie<T>(value: T): T {
  if (typeof value === 'string') return typographieFr(value) as T
  if (Array.isArray(value)) return value.map(typographie) as T
  if (value && typeof value === 'object') {
    return Object.fromEntries(Object.entries(value).map(([k, v]) => [k, typographie(v)])) as T
  }
  return value
}

/** Vérifie qu'une chaîne fait partie des valeurs autorisées. */
export function oneOf<T extends string>(value: string, allowed: readonly T[]): T {
  if (!(allowed as readonly string[]).includes(value)) {
    throw new Error(`Valeur inattendue « ${value} » (attendu : ${allowed.join(', ')})`)
  }
  return value as T
}

export const niveau = (value: string) => oneOf(value, NIVEAUX)

interface AlerteJson {
  id: string
  zone: string
  niveau: string
  titre: string
  corps: string
  statut: string
  date: string
  source: string
  probabilite?: number
  signalementsConfirmes?: number
}

export function alerte({ zone, niveau: n, statut, ...rest }: AlerteJson): Alerte {
  return { ...rest, zoneId: zone, niveau: niveau(n), statut: oneOf(statut, STATUTS_ALERTE) }
}

interface SignalementJson {
  id: string
  zone: string
  rue: string
  statut: string
  oui: number
  non: number
  il: string
  svg: { x: number; y: number }
  distanceUtilisateur?: string
  hauteurEau?: string
  svgTroncon?: string
  svgEtiquette?: { x: number; y: number }
  apresOui?: { statut: string; oui: number; non: number }
}

export function signalement({ zone, statut, svg, apresOui, ...rest }: SignalementJson): Signalement {
  return {
    ...rest,
    zoneId: zone,
    statut: oneOf(statut, STATUTS_SIGNALEMENT),
    position: svg,
    apresOui: apresOui && { ...apresOui, statut: oneOf(apresOui.statut, STATUTS_SIGNALEMENT) },
  }
}

interface SosJson {
  heure: string
  lieu: string
  personnes: number
  details: string
  statut: string
  svgDashboard: { x: number; y: number }
}

export function sos({ personnes, statut, svgDashboard, ...rest }: SosJson): Sos {
  return { ...rest, nbPersonnes: personnes, statut: oneOf(statut, STATUTS_SOS), positionDashboard: svgDashboard }
}

interface SosCourantJson {
  position: string
  precisionM: number
  personnes: number
  blesses: boolean
  hauteurEau: string
  enfantsOuAges: boolean
  timeline: SosCourant['timeline']
}

export function sosCourant({ position, personnes, ...rest }: SosCourantJson): SosCourant {
  return { ...rest, lieu: position, nbPersonnes: personnes }
}

interface UtilisateurJson {
  id: string
  prenom?: string
  nom?: string
  role: string
  quartierPrincipal?: string
  zonesSuivies?: string[]
  canaux?: Partial<Record<string, boolean>>
  scoreFiabilite?: number
  service?: string
}

export function utilisateur(json: UtilisateurJson): Utilisateur {
  return {
    id: json.id,
    // Citoyen : prénom (« Bonjour Awa ») ; agent : nom complet.
    nom: json.prenom ?? json.nom ?? '',
    role: oneOf(json.role, ROLES),
    quartierPrincipal: json.quartierPrincipal,
    zonesSuivies: json.zonesSuivies ?? [],
    canauxPreferes: CANAUX.filter((c) => json.canaux?.[c] === true),
    scoreFiabilite: json.scoreFiabilite,
    service: json.service,
  }
}

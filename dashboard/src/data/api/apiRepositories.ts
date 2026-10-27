import type { LineString, MultiPolygon } from 'geojson'
import dashboardFixture from '../../fixtures/dashboard.json'
import { fr } from '../../i18n/fr'
import { statutSosSuivant, type Alerte, type Compte, type NiveauInfo, type NiveauRisque, type Position, type PointSvg,
  type Role, type Signalement, type Sos, type StatutAlerte, type StatutSignalement, type StatutSos, type Utilisateur,
  type Zone } from '../models'
import { typographie } from '../mock/parse'
import type { Repositories } from '../repositories'
import { api } from './client'
import { dateAlerte, depuis, heure, jourLong } from './format'

// Dépôts du mode réel : API Hydrotic (FastAPI + Neon), jeton Clerk de l'agent connecté.

const menuFixe = typographie(dashboardFixture).menu
const ORIGINE: PointSvg = { x: 0, y: 0 }

interface ZoneApi extends Omit<Zone, 'contour' | 'centre'> {
  contour: MultiPolygon | null
  centre: [number, number] | null
}
interface AlerteApi {
  id: string; zoneId: string; niveau: NiveauRisque; titre: string; corps: string; statut: StatutAlerte
  probabilite: number | null; signalementsConfirmes: number | null; source: string; creeLe: string
}
interface SignalementApi {
  id: string; zoneId: string; rue: string | null; statut: StatutSignalement; oui: number; non: number; creeLe: string
  position: Position | null; troncon: LineString | null; svg: PointSvg | null; svgTroncon: string | null
  svgEtiquette: PointSvg | null; hauteurEau: string | null; distanceM: number | null
}
interface SosApi {
  id: string; lieu: string; position: Position | null; svgDashboard: PointSvg | null; nbPersonnes: number
  details: string | null; statut: StatutSos; creeLe: string
}
interface MoiApi {
  id: string; nom: string; email: string | null; role: Role; service: string | null; scoreFiabilite: number
  canauxPreferes: ('push' | 'email')[]; zonesSuivies: string[]
}
interface TableauApi {
  majLe: string
  agent: { nom: string; service: string | null }
  zonesEnAlerte: { n: number; total: number; parNiveau: { rouge: number; orange: number } }
  sos: { actifs: number; nonPrisEnCharge: number }
  signalements: { confirmes: number; recus: number; fenetreHeures: number }
  alertesDelivrees: number | null
  badges: { alertes: number; sos: number }
}

const alerte = (a: AlerteApi): Alerte => ({
  id: a.id, zoneId: a.zoneId, niveau: a.niveau, titre: a.titre, corps: a.corps, statut: a.statut,
  date: dateAlerte(a.creeLe), source: a.source,
  probabilite: a.probabilite ?? undefined, signalementsConfirmes: a.signalementsConfirmes ?? undefined,
})

const signalement = (s: SignalementApi): Signalement => ({
  id: s.id, zoneId: s.zoneId, rue: s.rue ?? fr.positionSignalee, statut: s.statut, oui: s.oui, non: s.non,
  il: depuis(s.creeLe), position: s.svg ?? undefined, geo: s.position, troncon: s.troncon,
  hauteurEau: s.hauteurEau ?? undefined, svgTroncon: s.svgTroncon ?? undefined, svgEtiquette: s.svgEtiquette ?? undefined,
  distanceUtilisateur: s.distanceM !== null ? `${s.distanceM} m` : undefined,
})

const sos = (s: SosApi): Sos => ({
  id: s.id, geo: s.position, heure: heure(new Date(s.creeLe)), lieu: s.lieu, nbPersonnes: s.nbPersonnes,
  details: s.details ?? '', statut: s.statut, positionDashboard: s.svgDashboard ?? ORIGINE,
})

const utilisateur = (u: MoiApi): Utilisateur => ({
  id: u.id, nom: u.nom, role: u.role, zonesSuivies: u.zonesSuivies, canauxPreferes: u.canauxPreferes,
  scoreFiabilite: u.scoreFiabilite, service: u.service ?? undefined, email: u.email,
})

export function createApiRepositories(): Repositories {
  const zones = async () => (await api<ZoneApi[]>('/api/zones')) as Zone[]
  const alertes = async () => (await api<AlerteApi[]>('/api/agent/alertes')).map(alerte)
  const moi = async () => utilisateur(await api<MoiApi>('/api/moi'))
  const tableau = () => api<TableauApi>('/api/agent/tableau')

  return {
    zones: {
      zones,
      zone: async (id) => {
        const z = (await zones()).find((x) => x.id === id)
        if (!z) throw new Error(`Zone inconnue : ${id}`)
        return z
      },
    },
    risk: {
      niveaux: () => api<Record<NiveauRisque, NiveauInfo>>('/api/niveaux'),
      risqueZone: async (zoneId) => {
        const r = await api<{ zoneId: string; aujourdhui: NiveauRisque; demain: NiveauRisque;
          signalementsConfirmes: number; majLe: string | null }>(`/api/zones/${zoneId}/risque`)
        return { ...r, majIl: r.majLe ? depuis(r.majLe) : '—' }
      },
      pluie: async (zoneId = 'treichville') =>
        (await api<{ jours: { label: string; mm: number; prevision: boolean }[] }>(`/api/zones/${zoneId}/pluie`)).jours,
      consignes: (niveau) => api<string[]>(`/api/consignes/${niveau}`),
    },
    alerts: {
      alertes,
      alerte: async (id) => {
        const a = (await alertes()).find((x) => x.id === id)
        if (!a) throw new Error(`Alerte inconnue : ${id}`)
        return a
      },
      modeles: () => api<Record<string, string>>('/api/agent/modeles'),
      valider: async (id) => void (await api(`/api/agent/alertes/${id}/valider`, { methode: 'POST' })),
      annuler: async (id) => void (await api(`/api/agent/alertes/${id}/annuler`, { methode: 'POST' })),
    },
    reports: {
      signalements: async () => (await api<SignalementApi[]>('/api/signalements')).map(signalement),
      positionUtilisateur: async () => ORIGINE,
      ajouter: async () => {
        throw new Error('Les signalements se font depuis l’application mobile')
      },
    },
    sos: {
      sosCourant: async () => {
        throw new Error('Le SOS se déclenche depuis l’application mobile')
      },
      liste: async () => (await api<SosApi[]>('/api/agent/sos')).map(sos),
      avancer: async (s) =>
        void (await api(`/api/agent/sos/${s.id}`, { methode: 'PATCH', corps: { statut: statutSosSuivant(s.statut) } })),
    },
    users: {
      citoyen: moi,
      agent: moi,
      comptes: () => api<Compte[]>('/api/admin/utilisateurs'),
      changerRole: async (id, role, service) =>
        void (await api(`/api/admin/utilisateurs/${id}`, { methode: 'PATCH', corps: { role, service } })),
    },
    dashboard: {
      entete: async () => {
        const t = await tableau()
        return {
          titre: fr.vueEnsemble,
          sousTitre: `${jourLong(new Date(t.majLe))} · ${fr.misAJourA(heure(new Date(t.majLe)))} · ${fr.agent(t.agent.service ?? t.agent.nom)}`,
        }
      },
      kpis: async () => {
        const t = await tableau()
        const z = t.zonesEnAlerte
        return [
          { libelle: fr.kpiZones, valeur: `${z.n} / ${z.total}`, detail: fr.parNiveau(z.parNiveau.rouge, z.parNiveau.orange) },
          { libelle: fr.kpiSosActifs, valeur: String(t.sos.actifs), detail: fr.nonPrisEnCharge(t.sos.nonPrisEnCharge) },
          { libelle: fr.kpiSignalements, valeur: String(t.signalements.confirmes),
            detail: fr.surRecus(t.signalements.recus, t.signalements.fenetreHeures) },
          { libelle: fr.kpiAlertesDelivrees, valeur: t.alertesDelivrees === null ? '—' : `${t.alertesDelivrees}`,
            detail: fr.envoiPhase3 },
        ]
      },
      menu: async () => {
        const t = await tableau()
        return menuFixe.map((m) => ({
          id: m.id, libelle: m.libelle,
          badge: m.id === 'alertes' ? t.badges.alertes || undefined : m.id === 'sos' ? t.badges.sos || undefined : undefined,
        }))
      },
      signalementsCarte: async () => [],
    },
  }
}

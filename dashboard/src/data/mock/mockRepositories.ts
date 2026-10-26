import alertsJson from '../../fixtures/alerts.json'
import dashboardJson from '../../fixtures/dashboard.json'
import reportsJson from '../../fixtures/reports.json'
import riskJson from '../../fixtures/risk.json'
import sosJson from '../../fixtures/sos.json'
import userJson from '../../fixtures/user.json'
import zonesJson from '../../fixtures/zones.json'
import { NIVEAUX, type NiveauInfo, type NiveauRisque, type Signalement } from '../models'
import type { Repositories } from '../repositories'
import * as parse from './parse'

// Dépôts « mock » : lisent les fixtures, sans réseau. Les modifications restent en mémoire.

function find<T>(items: T[], predicate: (item: T) => boolean, what: string): T {
  const item = items.find(predicate)
  if (!item) throw new Error(`Introuvable : ${what}`)
  return item
}

export function createMockRepositories(): Repositories {
  /** Signalements ajoutés localement. */
  const ajouts: Signalement[] = []

  const zones = async () => zonesJson.zones
  const alertes = async () => alertsJson.alertes.map(parse.alerte)

  return {
    zones: {
      zones,
      zone: async (id) => find(await zones(), (z) => z.id === id, `zone ${id}`),
    },

    risk: {
      niveaux: async () =>
        Object.fromEntries(NIVEAUX.map((n) => [n, riskJson.niveaux[n]])) as Record<NiveauRisque, NiveauInfo>,
      risqueZone: async (zoneId) => {
        const json = riskJson.parZone[zoneId as keyof typeof riskJson.parZone]
        if (!json) throw new Error(`Introuvable : risque ${zoneId}`)
        return {
          zoneId,
          aujourdhui: parse.niveau(json.aujourdhui),
          demain: parse.niveau(json.demain),
          signalementsConfirmes: json.signalementsConfirmes,
          majIl: json.majIl,
        }
      },
      pluie: async () =>
        riskJson.pluie.labels.map((label, i) => ({
          label,
          mm: riskJson.pluie.mm[i],
          prevision: riskJson.pluie.prevision[i],
        })),
      consignes: async (niveau) => {
        const consignes: Partial<Record<NiveauRisque, string[]>> = riskJson.consignes
        return consignes[niveau] ?? []
      },
    },

    alerts: {
      alertes,
      alerte: async (id) => find(await alertes(), (a) => a.id === id, `alerte ${id}`),
      modeles: async () => alertsJson.modeles,
    },

    reports: {
      signalements: async () => [...reportsJson.signalements.map(parse.signalement), ...ajouts],
      positionUtilisateur: async () => reportsJson.utilisateur.svg,
      ajouter: async (signalement) => {
        ajouts.push(signalement)
      },
    },

    sos: {
      sosCourant: async () => parse.sosCourant(sosJson.sosCourant),
      liste: async () => sosJson.liste.map(parse.sos),
    },

    users: {
      citoyen: async () => parse.utilisateur(userJson.citoyen),
      agent: async () => parse.utilisateur(userJson.agent),
    },

    dashboard: {
      entete: async () => dashboardJson.entete,
      kpis: async () => dashboardJson.kpis,
      menu: async () => dashboardJson.menu,
      signalementsCarte: async () => dashboardJson.signalementsCarte,
    },
  }
}

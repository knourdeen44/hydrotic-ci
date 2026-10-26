// Textes affichés du tableau de bord (français), centralisés pour préparer d'autres langues.
import { NBSP } from '../data/mock/parse'
import type { StatutAlerte, StatutSignalement, StatutSos } from '../data/models'

export { NBSP }

/** Nombre décimal à la française (0.82 → « 0,82 »). */
export const decimal = (n: number) => String(n).replace('.', ',')

export const fr = {
  nomApp: 'Hydrotic CI',
  espaceAutorites: 'Espace autorités',
  modeDemo: 'Mode démonstration — données fictives',
  bientot: 'Disponible dans une prochaine version',
  alerteManuelle: '+ Alerte manuelle',

  // D1 — Vue d'ensemble
  carteTitre: 'Carte des risques, signalements et victimes',
  schemaIllustratif: 'Schéma illustratif',
  legendeVictime: 'Victime (SOS)',
  legendeSignalement: 'Signalement confirmé',
  legendeZoneRouge: 'Zone rouge',
  legendeZoneOrange: 'Zone orange',
  alerteEnAttente: 'Alerte en attente de validation',
  probabilite: (p: number) => `probabilité ${decimal(p)}`,
  signalementsConfirmes: (n: number, lieu: string) => `${n} signalements confirmés ${lieu}`,
  message: `Message${NBSP}: `,
  validerEnvoyer: 'Valider et envoyer',
  modifier: 'Modifier',
  annuler: 'Annuler',
  envoyee: '✓ Envoyée · push + e-mail',
  sosVictimes: 'SOS victimes',
  tempsReel: 'temps réel',
  colonnesSos: ['Heure', 'Lieu', 'Pers.', 'Détails', 'Statut'],

  // D2 à D8
  colonnesAlertes: ['Niveau', 'Zone', 'Titre', 'Date', 'Statut', 'Source'],
  toutesZones: 'Toutes les zones',
  tousNiveaux: 'Tous les niveaux',
  filtreZone: 'Filtrer par zone',
  filtreNiveau: 'Filtrer par niveau',
  carteSos: 'Carte des victimes',
  colonnesSignalements: ['Rue', 'Zone', '« oui »', '« non »', 'Statut', 'Il y a'],
  aujourdhui: "Aujourd'hui",
  demain: 'Demain',
  pluieTitre: 'Pluie (mm) — 5 derniers jours et prévision',
  exporterCsv: 'Exporter en CSV',
  zonesEtSousZones: 'Zones et sous-zones',
  seuilsTitre: 'Seuils de niveau (lecture seule)',
  colonnesSeuils: ['Niveau', 'Probabilité'],
  seuils: [
    ['vert', `< 20${NBSP}%`],
    ['jaune', `20–40${NBSP}%`],
    ['orange', `40–70${NBSP}%`],
    ['rouge', `> 70${NBSP}%`],
  ] as const,
  supervision: ['Collecte des données', 'Modèle de prévision', 'Envoi des alertes'],
  nonConnecte: 'Non connecté (phase 1)',

  statutAlerte: { ENVOYEE: 'Envoyée', EN_ATTENTE: 'En attente' } satisfies Record<StatutAlerte, string>,
  statutSignalement: { A_CONFIRMER: 'À confirmer', CONFIRME: 'Confirmé' } satisfies Record<StatutSignalement, string>,
  statutSos: { RECU: 'Reçu', EN_ROUTE: 'En route', SECOURU: 'Secouru' } satisfies Record<StatutSos, string>,
}

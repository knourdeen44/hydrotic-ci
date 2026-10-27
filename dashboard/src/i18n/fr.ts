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

  // Mode démo (Ctrl + D)
  modeDemoTitre: 'Mode démonstration',
  scenario1: 'Scénario 1 — Alerte la veille',
  scenario2: 'Scénario 2 — Confirmation rue Ministre',
  scenario3: 'Scénario 3 — SOS',
  scenario4: 'Scénario 4 — Tableau de bord',
  reinitialiser: 'Réinitialiser les données',
  applicationMobile: 'application mobile ↗',

  // D1 — Vue d'ensemble
  /** Libellé de l'indicateur recalculé depuis la liste des SOS (`dashboard.json > kpis`). */
  kpiSosActifs: 'SOS actifs',
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

  // Mode réel (API)
  vueEnsemble: "Vue d'ensemble",
  misAJourA: (h: string) => `mise à jour à ${h}`,
  agent: (qui: string) => `Agent${NBSP}: ${qui}`,
  kpiZones: 'Zones en alerte',
  parNiveau: (rouge: number, orange: number) => `${rouge} rouge · ${orange} orange`,
  nonPrisEnCharge: (n: number) => `${n} non pris en charge`,
  kpiSignalements: 'Signalements confirmés',
  surRecus: (n: number, h: number) => `sur ${n} reçus (${h}${NBSP}h)`,
  kpiAlertesDelivrees: 'Alertes délivrées',
  envoiPhase3: 'envoi réel en phase 3',
  positionSignalee: 'Position signalée',
  erreurChargement: 'Impossible de joindre le serveur. Nouvel essai dans quelques secondes.',
  carteReelleTitre: 'Carte des risques, signalements et victimes',
  attributionOsm: '© contributeurs OpenStreetMap',

  // Connexion et comptes
  connexionSousTitre: 'Connectez-vous avec votre compte agent.',
  accesReserve: 'Accès réservé aux agents',
  accesReserveDetail: (email: string) =>
    `Votre compte (${email}) est un compte citoyen. Demandez à un administrateur de vous nommer agent.`,
  seDeconnecter: 'Se déconnecter',
  comptes: 'Comptes',
  colonnesComptes: ['Nom', 'E-mail', 'Rôle', 'Service', ''],
  roles: { CITOYEN: 'Citoyen', AGENT: 'Agent', ADMIN: 'Administrateur' } as const,
  enregistrer: 'Enregistrer',
  enregistre: 'Enregistré',
  modeDonneesReelles: 'Données réelles',
  passerDemo: 'Passer en mode démonstration (données fictives)',
  passerReel: 'Revenir aux données réelles',

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

  statutAlerte: { ENVOYEE: 'Envoyée', EN_ATTENTE: 'En attente', ANNULEE: 'Annulée' } satisfies Record<StatutAlerte, string>,
  statutSignalement: { A_CONFIRMER: 'À confirmer', CONFIRME: 'Confirmé' } satisfies Record<StatutSignalement, string>,
  statutSos: { RECU: 'Reçu', EN_ROUTE: 'En route', SECOURU: 'Secouru' } satisfies Record<StatutSos, string>,
}

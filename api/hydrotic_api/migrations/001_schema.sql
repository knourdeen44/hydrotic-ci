-- Schéma initial (phase 2). Noms repris du diagramme docs/uml_classes.png.
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TYPE niveau_risque AS ENUM ('vert', 'jaune', 'orange', 'rouge');
CREATE TYPE role_utilisateur AS ENUM ('CITOYEN', 'AGENT', 'ADMIN');
CREATE TYPE statut_alerte AS ENUM ('EN_ATTENTE', 'ENVOYEE', 'ANNULEE');
CREATE TYPE statut_signalement AS ENUM ('A_CONFIRMER', 'CONFIRME');
CREATE TYPE statut_sos AS ENUM ('RECU', 'EN_ROUTE', 'SECOURU');
CREATE TYPE reponse_confirmation AS ENUM ('oui', 'non', 'inconnu');

-- Utilisateur : identifiant Clerk ; le rôle est géré ici (les agents sont promus par un administrateur).
CREATE TABLE utilisateur (
  id              text PRIMARY KEY,
  prenom          text,
  nom             text,
  email           text,
  role            role_utilisateur NOT NULL DEFAULT 'CITOYEN',
  service         text,
  score_fiabilite numeric(4, 2) NOT NULL DEFAULT 1.0,
  canaux          text[] NOT NULL DEFAULT ARRAY['push', 'email'],
  cree_le         timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE zone (
  id                  text PRIMARY KEY,
  nom                 text NOT NULL,
  commune             text NOT NULL,
  profil              text NOT NULL,
  sous_zones          text[] NOT NULL DEFAULT '{}',
  -- Contour réel (OpenStreetMap, étape 2) ; contours schématiques gardés pour le mode démo.
  contour             geography(MultiPolygon, 4326),
  svg_mobile          text,
  svg_dashboard       text,
  etiquette_dashboard jsonb
);

CREATE TABLE zone_suivie (
  utilisateur_id text REFERENCES utilisateur (id) ON DELETE CASCADE,
  zone_id        text REFERENCES zone (id),
  PRIMARY KEY (utilisateur_id, zone_id)
);

-- Textes associés aux niveaux et consignes (risk.json).
CREATE TABLE niveau_info (
  niveau  niveau_risque PRIMARY KEY,
  label   text NOT NULL,
  titre   text NOT NULL,
  message text NOT NULL
);

CREATE TABLE consigne (
  niveau niveau_risque NOT NULL,
  rang   smallint NOT NULL,
  texte  text NOT NULL,
  PRIMARY KEY (niveau, rang)
);

-- Prévision de risque d'une zone pour un jour (UML : Prediction).
CREATE TABLE prevision (
  zone_id        text REFERENCES zone (id),
  jour           date NOT NULL,
  niveau         niveau_risque NOT NULL,
  probabilite    numeric(3, 2),
  version_modele text NOT NULL DEFAULT 'saisie agent',
  PRIMARY KEY (zone_id, jour)
);

-- Pluie observée ou prévue à Abidjan (UML : Observation ; Open-Meteo à l'étape 2).
CREATE TABLE observation (
  jour      date NOT NULL,
  pluie_mm  numeric(6, 1) NOT NULL,
  prevision boolean NOT NULL DEFAULT false,
  source    text NOT NULL,
  maj_le    timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (jour, source)
);

CREATE TABLE modele_message (
  cle   text PRIMARY KEY,
  texte text NOT NULL
);

CREATE TABLE alerte (
  id                     text PRIMARY KEY DEFAULT gen_random_uuid()::text,
  zone_id                text NOT NULL REFERENCES zone (id),
  niveau                 niveau_risque NOT NULL,
  titre                  text NOT NULL,
  corps                  text NOT NULL,
  statut                 statut_alerte NOT NULL DEFAULT 'EN_ATTENTE',
  probabilite            numeric(3, 2),
  signalements_confirmes integer,
  source                 text NOT NULL DEFAULT 'Modèle Hydrotic',
  cree_le                timestamptz NOT NULL DEFAULT now(),
  validee_par            text REFERENCES utilisateur (id),
  validee_le             timestamptz
);

CREATE TABLE signalement (
  id            text PRIMARY KEY DEFAULT gen_random_uuid()::text,
  zone_id       text NOT NULL REFERENCES zone (id),
  rue           text NOT NULL,
  statut        statut_signalement NOT NULL DEFAULT 'A_CONFIRMER',
  oui           integer NOT NULL DEFAULT 0,
  non           integer NOT NULL DEFAULT 0,
  position      geography(Point, 4326),
  troncon       geography(LineString, 4326),
  svg           jsonb,
  svg_troncon   text,
  svg_etiquette jsonb,
  hauteur_eau   text,
  description   text,
  auteur_id     text REFERENCES utilisateur (id),
  cree_le       timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE confirmation (
  signalement_id text REFERENCES signalement (id) ON DELETE CASCADE,
  utilisateur_id text REFERENCES utilisateur (id) ON DELETE CASCADE,
  reponse        reponse_confirmation NOT NULL,
  position       geography(Point, 4326),
  cree_le        timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (signalement_id, utilisateur_id)
);

CREATE TABLE sos (
  id                 text PRIMARY KEY DEFAULT gen_random_uuid()::text,
  auteur_id          text REFERENCES utilisateur (id),
  lieu               text NOT NULL,
  position           geography(Point, 4326),
  precision_m        numeric(7, 1),
  svg_dashboard      jsonb,
  nb_personnes       integer NOT NULL DEFAULT 1,
  blesses            boolean NOT NULL DEFAULT false,
  hauteur_eau        text,
  enfants_ou_ages    boolean NOT NULL DEFAULT false,
  details            text,
  statut             statut_sos NOT NULL DEFAULT 'RECU',
  canal_envoi        text NOT NULL DEFAULT 'internet',
  pris_en_charge_par text REFERENCES utilisateur (id),
  cree_le            timestamptz NOT NULL DEFAULT now()
);

-- Suivi d'un SOS (étapes « Reçu », « Équipe en route », « Secouru »).
CREATE TABLE sos_evenement (
  sos_id  text REFERENCES sos (id) ON DELETE CASCADE,
  statut  statut_sos NOT NULL,
  detail  text NOT NULL DEFAULT '',
  cree_le timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (sos_id, statut)
);

CREATE INDEX signalement_zone ON signalement (zone_id);
CREATE INDEX sos_statut ON sos (statut);
CREATE INDEX alerte_zone ON alerte (zone_id, cree_le DESC);

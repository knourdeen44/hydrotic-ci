-- Actions réelles (étape 3) : signalements créés depuis le téléphone, prévisions saisies par les agents.

-- Un signalement envoyé depuis M7 n'a pas forcément de nom de rue.
ALTER TABLE signalement ALTER COLUMN rue DROP NOT NULL;

-- Qui a fixé le niveau d'une prévision, et quand (« mise à jour il y a … »).
ALTER TABLE prevision
  ADD COLUMN maj_le  timestamptz NOT NULL DEFAULT now(),
  ADD COLUMN maj_par text REFERENCES utilisateur (id);

-- Qui a annulé une alerte (la validation a déjà validee_par / validee_le).
ALTER TABLE alerte
  ADD COLUMN annulee_par text REFERENCES utilisateur (id),
  ADD COLUMN annulee_le  timestamptz;

CREATE INDEX signalement_position ON signalement USING gist (position);
CREATE INDEX utilisateur_email ON utilisateur (lower(email));

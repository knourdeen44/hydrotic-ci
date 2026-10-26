-- Pluie par zone (Open-Meteo au centre de chaque quartier) ; remplace la pluie unique des fixtures.
DROP TABLE observation;

CREATE TABLE observation (
  zone_id   text NOT NULL REFERENCES zone (id),
  jour      date NOT NULL,
  pluie_mm  numeric(6, 1) NOT NULL,
  prevision boolean NOT NULL DEFAULT false,
  source    text NOT NULL,
  maj_le    timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (zone_id, jour, source)
);

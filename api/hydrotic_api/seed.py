"""Données de départ : reprend les fixtures de la phase 1 (fixtures/*.json).

Idempotent (on peut le relancer). Les dates relatives (« il y a 38 min », aujourd'hui, demain)
sont recalculées à partir de maintenant. Usage : uv run python -m hydrotic_api.seed
"""
import json
import re
from datetime import date, datetime, timedelta, timezone
from pathlib import Path

import psycopg
from psycopg.types.json import Jsonb

from .db import connexion

FIXTURES = Path(__file__).resolve().parents[2] / "fixtures"
OSM = Path(__file__).resolve().parent / "donnees" / "osm.geojson"
MOIS = ["janvier", "février", "mars", "avril", "mai", "juin", "juillet", "août",
        "septembre", "octobre", "novembre", "décembre"]
ANNEE_FIXTURES = 2026  # « Mercredi 17 juin » : mercredi 17 juin 2026


def _lire(nom: str) -> dict:
    return json.loads((FIXTURES / f"{nom}.json").read_text(encoding="utf-8"))


def date_fixture(texte: str) -> datetime:
    """« Mercredi 17 juin · 18:42 » → 2026-06-17 18:42 (heure d'Abidjan = UTC)."""
    jour, heure = texte.split(" · ")
    _, numero, mois = jour.split(" ")
    h, m = heure.split(":")
    return datetime(ANNEE_FIXTURES, MOIS.index(mois) + 1, int(numero), int(h), int(m), tzinfo=timezone.utc)


def anciennete(texte: str) -> timedelta:
    """« 38 min » / « 1 h » → durée."""
    nombre, unite = re.fullmatch(r"(\d+) (min|h)", texte).groups()
    return timedelta(minutes=int(nombre)) if unite == "min" else timedelta(hours=int(nombre))


def peupler(conn: psycopg.Connection, aujourdhui: date | None = None) -> None:
    aujourdhui = aujourdhui or datetime.now(timezone.utc).date()
    maintenant = datetime.now(timezone.utc)
    zones, risk, alerts = _lire("zones"), _lire("risk"), _lire("alerts")
    reports, sos = _lire("reports"), _lire("sos")

    for z in zones["zones"]:
        conn.execute(
            """INSERT INTO zone (id, nom, commune, profil, sous_zones, svg_mobile, svg_dashboard, etiquette_dashboard)
               VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
               ON CONFLICT (id) DO UPDATE SET nom = EXCLUDED.nom, commune = EXCLUDED.commune,
                 profil = EXCLUDED.profil, sous_zones = EXCLUDED.sous_zones, svg_mobile = EXCLUDED.svg_mobile,
                 svg_dashboard = EXCLUDED.svg_dashboard, etiquette_dashboard = EXCLUDED.etiquette_dashboard""",
            (z["id"], z["nom"], z["commune"], z["profil"], z["sousZones"], z["svgMobile"], z["svgDashboard"],
             Jsonb(z.get("etiquetteDashboard"))),
        )

    for niveau, info in risk["niveaux"].items():
        conn.execute(
            """INSERT INTO niveau_info (niveau, label, titre, message) VALUES (%s, %s, %s, %s)
               ON CONFLICT (niveau) DO UPDATE SET label = EXCLUDED.label, titre = EXCLUDED.titre,
                 message = EXCLUDED.message""",
            (niveau, info["label"], info["titre"], info["message"]),
        )
    for niveau, consignes in risk["consignes"].items():
        for rang, texte in enumerate(consignes, start=1):
            conn.execute(
                """INSERT INTO consigne (niveau, rang, texte) VALUES (%s, %s, %s)
                   ON CONFLICT (niveau, rang) DO UPDATE SET texte = EXCLUDED.texte""",
                (niveau, rang, texte),
            )
    for zone_id, r in risk["parZone"].items():
        for decalage, niveau in ((0, r["aujourdhui"]), (1, r["demain"])):
            conn.execute(
                """INSERT INTO prevision (zone_id, jour, niveau) VALUES (%s, %s, %s)
                   ON CONFLICT (zone_id, jour) DO UPDATE SET niveau = EXCLUDED.niveau""",
                (zone_id, aujourdhui + timedelta(days=decalage), niveau),
            )

    for cle, texte in alerts["modeles"].items():
        conn.execute(
            "INSERT INTO modele_message (cle, texte) VALUES (%s, %s) ON CONFLICT (cle) DO UPDATE SET texte = EXCLUDED.texte",
            (cle, texte),
        )
    for a in alerts["alertes"]:
        conn.execute(
            """INSERT INTO alerte (id, zone_id, niveau, titre, corps, statut, probabilite, signalements_confirmes,
                 source, cree_le)
               VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s) ON CONFLICT (id) DO NOTHING""",
            (a["id"], a["zone"], a["niveau"], a["titre"], a["corps"], a["statut"], a.get("probabilite"),
             a.get("signalementsConfirmes"), a["source"], date_fixture(a["date"])),
        )

    for s in reports["signalements"]:
        conn.execute(
            """INSERT INTO signalement (id, zone_id, rue, statut, oui, non, svg, svg_troncon, svg_etiquette,
                 hauteur_eau, cree_le)
               VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s) ON CONFLICT (id) DO NOTHING""",
            (s["id"], s["zone"], s["rue"], s["statut"], s["oui"], s["non"], Jsonb(s["svg"]), s.get("svgTroncon"),
             Jsonb(s.get("svgEtiquette")), s.get("hauteurEau"), maintenant - anciennete(s["il"])),
        )

    for i, v in enumerate(sos["liste"], start=1):
        h, m = (int(x) for x in v["heure"].split(":"))
        recu = datetime.combine(aujourdhui, datetime.min.time(), timezone.utc).replace(hour=h, minute=m)
        conn.execute(
            """INSERT INTO sos (id, lieu, nb_personnes, details, statut, svg_dashboard, cree_le)
               VALUES (%s, %s, %s, %s, %s, %s, %s) ON CONFLICT (id) DO NOTHING""",
            (f"sos-{i}", v["lieu"], v["personnes"], v["details"], v["statut"], Jsonb(v["svgDashboard"]), recu),
        )
    _geometries_osm(conn)
    conn.commit()


def _geometries_osm(conn: psycopg.Connection) -> None:
    """Contours, tronçon et positions réels (OpenStreetMap, outils/importer_osm.py)."""
    requetes = {
        "zone": "UPDATE zone SET contour = ST_Multi(ST_GeomFromGeoJSON(%s))::geography WHERE id = %s",
        "troncon": "UPDATE signalement SET troncon = ST_GeomFromGeoJSON(%s)::geography WHERE id = %s",
        "signalement": "UPDATE signalement SET position = ST_GeomFromGeoJSON(%s)::geography WHERE id = %s",
        "sos": "UPDATE sos SET position = ST_GeomFromGeoJSON(%s)::geography WHERE id = %s",
    }
    for entite in json.loads(OSM.read_text(encoding="utf-8"))["features"]:
        proprietes = entite["properties"]
        conn.execute(requetes[proprietes["type"]], (json.dumps(entite["geometry"]), proprietes["id"]))


if __name__ == "__main__":
    with connexion() as c:
        peupler(c)
    print("Données de départ chargées.")

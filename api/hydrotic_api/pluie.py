"""Pluie réelle par quartier : Open-Meteo (gratuit, sans clé, usage non commercial).

Cumul quotidien des 4 derniers jours, d'aujourd'hui et des 2 prochains jours, au centre du quartier.
Mis en cache une heure en base ; si Open-Meteo ne répond pas, les dernières valeurs connues servent.
Données météo : Open-Meteo.com, licence CC BY 4.0.
"""
from datetime import date, datetime, timedelta, timezone

import httpx
import psycopg

OPEN_METEO = "https://api.open-meteo.com/v1/forecast"
SOURCE = "open-meteo"
ATTRIBUTION = "Données météo : Open-Meteo.com (CC BY 4.0)"
DUREE_CACHE = timedelta(hours=1)
JOURS_PASSES, JOURS_A_VENIR = 4, 2


class PluieIndisponible(Exception):
    """Ni Open-Meteo ni le cache ne peuvent fournir la pluie."""


def libelle(decalage: int) -> str:
    """-4 → « J-4 », 0 → « Auj. », 2 → « J+2 » (libellés de l'accueil)."""
    return "Auj." if decalage == 0 else f"J{decalage:+d}"


def _interroger(latitude: float, longitude: float) -> list[tuple[date, float]]:
    r = httpx.get(
        OPEN_METEO,
        params={
            "latitude": round(latitude, 4),
            "longitude": round(longitude, 4),
            "daily": "precipitation_sum",
            "past_days": JOURS_PASSES,
            "forecast_days": JOURS_A_VENIR + 1,
            "timezone": "Africa/Abidjan",
        },
        timeout=10,
    )
    r.raise_for_status()
    quotidien = r.json()["daily"]
    return [(date.fromisoformat(j), mm or 0.0) for j, mm in zip(quotidien["time"], quotidien["precipitation_sum"])]


def _en_cache(db: psycopg.Connection, zone_id: str, debut: date, fin: date) -> list[dict]:
    return db.execute(
        """SELECT jour, pluie_mm, maj_le FROM observation
           WHERE zone_id = %s AND source = %s AND jour BETWEEN %s AND %s ORDER BY jour""",
        (zone_id, SOURCE, debut, fin),
    ).fetchall()


def pluie_zone(db: psycopg.Connection, zone_id: str, maintenant: datetime | None = None) -> dict:
    maintenant = maintenant or datetime.now(timezone.utc)
    aujourdhui = maintenant.date()  # Abidjan : UTC+0
    debut, fin = aujourdhui - timedelta(days=JOURS_PASSES), aujourdhui + timedelta(days=JOURS_A_VENIR)

    lignes = _en_cache(db, zone_id, debut, fin)
    complet = len(lignes) == JOURS_PASSES + JOURS_A_VENIR + 1
    frais = complet and min(l["maj_le"] for l in lignes) > maintenant - DUREE_CACHE
    if not frais:
        centre = db.execute(
            "SELECT ST_Y(c) AS lat, ST_X(c) AS lon FROM (SELECT ST_Centroid(contour::geometry) AS c FROM zone WHERE id = %s) z",
            (zone_id,),
        ).fetchone()
        if centre is None or centre["lat"] is None:
            raise PluieIndisponible(f"contour inconnu pour la zone {zone_id}")
        try:
            for jour, mm in _interroger(centre["lat"], centre["lon"]):
                db.execute(
                    """INSERT INTO observation (zone_id, jour, pluie_mm, prevision, source, maj_le)
                       VALUES (%s, %s, %s, %s, %s, %s)
                       ON CONFLICT (zone_id, jour, source) DO UPDATE
                         SET pluie_mm = EXCLUDED.pluie_mm, prevision = EXCLUDED.prevision, maj_le = EXCLUDED.maj_le""",
                    (zone_id, jour, mm, jour > aujourdhui, SOURCE, maintenant),
                )
            db.commit()
            lignes = _en_cache(db, zone_id, debut, fin)
        except (httpx.HTTPError, KeyError, ValueError):
            db.rollback()
            if not lignes:
                raise PluieIndisponible("Open-Meteo indisponible et aucune donnée en cache") from None

    return {
        "source": "Open-Meteo",
        "attribution": ATTRIBUTION,
        "majLe": max(l["maj_le"] for l in lignes).isoformat(),
        "jours": [
            {
                "jour": l["jour"].isoformat(),
                "label": libelle((l["jour"] - aujourdhui).days),
                "mm": float(l["pluie_mm"]),
                "prevision": l["jour"] > aujourdhui,
            }
            for l in lignes
        ],
    }

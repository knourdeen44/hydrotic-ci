"""Informations publiques : quartiers, pluie, niveaux de risque, consignes (sans connexion)."""
from datetime import date, datetime, timedelta, timezone

import psycopg
from fastapi import APIRouter, Depends, HTTPException

from ..db import get_db
from ..pluie import PluieIndisponible, pluie_zone

routeur = APIRouter(prefix="/api", tags=["public"])
NIVEAUX = ("vert", "jaune", "orange", "rouge")


def zone_existe(db: psycopg.Connection, zone_id: str) -> None:
    if db.execute("SELECT 1 FROM zone WHERE id = %s", (zone_id,)).fetchone() is None:
        raise HTTPException(404, "Zone inconnue")


@routeur.get("/sante")
def sante(db: psycopg.Connection = Depends(get_db)) -> dict:
    """État de l'API et de la base."""
    ligne = db.execute("SELECT postgis_version() AS postgis, (SELECT count(*) FROM zone) AS zones").fetchone()
    return {"statut": "ok", "postgis": ligne["postgis"], "zones": ligne["zones"]}


@routeur.get("/zones")
def zones(db: psycopg.Connection = Depends(get_db)) -> list[dict]:
    """Quartiers : contour réel (GeoJSON, OpenStreetMap) et centre [longitude, latitude]."""
    lignes = db.execute(
        """SELECT id, nom, commune, profil, sous_zones, svg_mobile, svg_dashboard, etiquette_dashboard,
                  ST_AsGeoJSON(contour, 6)::json AS contour,
                  ST_AsGeoJSON(ST_Centroid(contour::geometry), 6)::json AS centre
           FROM zone ORDER BY id DESC"""
    ).fetchall()
    return [
        {
            "id": z["id"],
            "nom": z["nom"],
            "commune": z["commune"],
            "profil": z["profil"],
            "sousZones": z["sous_zones"],
            "svgMobile": z["svg_mobile"],
            "svgDashboard": z["svg_dashboard"],
            "etiquetteDashboard": z["etiquette_dashboard"],
            "contour": z["contour"],
            "centre": z["centre"]["coordinates"] if z["centre"] else None,
        }
        for z in lignes
    ]


@routeur.get("/zones/{zone_id}/pluie")
def pluie(zone_id: str, db: psycopg.Connection = Depends(get_db)) -> dict:
    """Pluie réelle (mm) : 4 derniers jours, aujourd'hui, 2 prochains jours (Open-Meteo)."""
    zone_existe(db, zone_id)
    try:
        return pluie_zone(db, zone_id)
    except PluieIndisponible as erreur:
        raise HTTPException(503, str(erreur)) from erreur


def niveau_du_jour(db: psycopg.Connection, zone_id: str, jour: date) -> dict | None:
    """Dernière prévision connue pour ce jour (ou la plus récente avant lui)."""
    return db.execute(
        "SELECT niveau, jour, maj_le FROM prevision WHERE zone_id = %s AND jour <= %s ORDER BY jour DESC LIMIT 1",
        (zone_id, jour),
    ).fetchone()


@routeur.get("/zones/{zone_id}/risque")
def risque(zone_id: str, db: psycopg.Connection = Depends(get_db)) -> dict:
    """Niveau d'aujourd'hui et de demain (fixés par les agents), signalements confirmés sur 24 h."""
    zone_existe(db, zone_id)
    aujourdhui = datetime.now(timezone.utc).date()
    jour, demain = niveau_du_jour(db, zone_id, aujourdhui), niveau_du_jour(db, zone_id, aujourdhui + timedelta(days=1))
    confirmes = db.execute(
        """SELECT count(*) AS n FROM signalement
           WHERE zone_id = %s AND statut = 'CONFIRME' AND cree_le > now() - interval '24 hours'""",
        (zone_id,),
    ).fetchone()["n"]
    maj = max((p["maj_le"] for p in (jour, demain) if p), default=None)
    return {
        "zoneId": zone_id,
        "aujourdhui": jour["niveau"] if jour else "vert",
        "demain": demain["niveau"] if demain else "vert",
        "signalementsConfirmes": confirmes,
        "majLe": maj.isoformat() if maj else None,
    }


@routeur.get("/niveaux")
def niveaux(db: psycopg.Connection = Depends(get_db)) -> dict:
    """Mot, titre et message de chaque niveau (vert, jaune, orange, rouge)."""
    lignes = db.execute("SELECT niveau, label, titre, message FROM niveau_info").fetchall()
    return {l["niveau"]: {"label": l["label"], "titre": l["titre"], "message": l["message"]} for l in lignes}


@routeur.get("/consignes/{niveau}")
def consignes(niveau: str, db: psycopg.Connection = Depends(get_db)) -> list[str]:
    """Consignes à suivre pour un niveau (liste vide pour « vert »)."""
    if niveau not in NIVEAUX:
        raise HTTPException(404, "Niveau inconnu")
    lignes = db.execute("SELECT texte FROM consigne WHERE niveau = %s ORDER BY rang", (niveau,)).fetchall()
    return [l["texte"] for l in lignes]

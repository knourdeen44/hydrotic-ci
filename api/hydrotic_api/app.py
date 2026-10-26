"""Application FastAPI."""
import psycopg
from fastapi import Depends, FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .auth import origines_autorisees, utilisateur_connecte
from .db import get_db

app = FastAPI(
    title="API Hydrotic CI",
    version="0.2.0",
    description="Prévention des inondations à Abidjan : zones, prévisions, alertes, signalements, SOS.",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=origines_autorisees(),
    allow_methods=["GET", "POST", "PATCH", "DELETE"],
    allow_headers=["Authorization", "Content-Type"],
)


@app.get("/")
def accueil() -> dict:
    return {"api": "Hydrotic CI", "version": app.version, "documentation": "/docs"}


@app.get("/api/sante")
def sante(db: psycopg.Connection = Depends(get_db)) -> dict:
    """État de l'API et de la base (sans authentification)."""
    ligne = db.execute("SELECT postgis_version() AS postgis, (SELECT count(*) FROM zone) AS zones").fetchone()
    return {"statut": "ok", "postgis": ligne["postgis"], "zones": ligne["zones"]}


@app.get("/api/zones")
def zones(db: psycopg.Connection = Depends(get_db)) -> list[dict]:
    """Quartiers suivis (contour réel en GeoJSON quand il est connu)."""
    lignes = db.execute(
        """SELECT id, nom, commune, profil, sous_zones, svg_mobile, svg_dashboard, etiquette_dashboard,
                  ST_AsGeoJSON(contour)::json AS contour
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
        }
        for z in lignes
    ]


@app.get("/api/moi")
def moi(jeton: dict = Depends(utilisateur_connecte), db: psycopg.Connection = Depends(get_db)) -> dict:
    """Profil de l'utilisateur connecté (créé comme citoyen à la première connexion)."""
    db.execute("INSERT INTO utilisateur (id) VALUES (%s) ON CONFLICT (id) DO NOTHING", (jeton["sub"],))
    u = db.execute(
        """SELECT u.id, u.prenom, u.nom, u.role, u.service, u.score_fiabilite, u.canaux,
                  coalesce(array_agg(zs.zone_id ORDER BY zs.zone_id DESC) FILTER (WHERE zs.zone_id IS NOT NULL), '{}')
                    AS zones_suivies
           FROM utilisateur u LEFT JOIN zone_suivie zs ON zs.utilisateur_id = u.id
           WHERE u.id = %s GROUP BY u.id""",
        (jeton["sub"],),
    ).fetchone()
    db.commit()
    return {
        "id": u["id"],
        "nom": u["prenom"] or u["nom"] or "",
        "role": u["role"],
        "service": u["service"],
        "scoreFiabilite": float(u["score_fiabilite"]),
        "canauxPreferes": u["canaux"],
        "zonesSuivies": u["zones_suivies"],
    }

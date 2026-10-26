"""Signalements d'inondation et confirmation communautaire (M3, M7, D4)."""
from typing import Literal

import psycopg
from fastapi import APIRouter, Depends, HTTPException, Query
from pydantic import BaseModel, Field

from ..db import get_db
from ..utilisateurs import utilisateur_courant

routeur = APIRouter(prefix="/api/signalements", tags=["signalements"])

# Règles de départ, à ajuster avec l'ONPC.
SEUIL_CONFIRMATION = 8          # « oui » nécessaires (données de départ : 7 → à confirmer, 8 → confirmé)
FENETRE = "72 hours"            # signalements affichés
BONUS_ACCORD, MALUS_DESACCORD = 0.1, 0.05
SCORE_MAX = 5

COLONNES = """s.id, s.zone_id, s.rue, s.statut, s.oui, s.non, s.cree_le, s.svg, s.svg_troncon, s.svg_etiquette,
  s.hauteur_eau, s.description, s.auteur_id,
  ST_X(s.position::geometry) AS lon, ST_Y(s.position::geometry) AS lat,
  ST_AsGeoJSON(s.troncon, 6)::json AS troncon,
  CASE WHEN %(lat)s::float8 IS NOT NULL THEN
    round(ST_Distance(s.position, ST_SetSRID(ST_MakePoint(%(lon)s::float8, %(lat)s::float8), 4326)::geography))
  END AS distance,
  c.reponse AS ma_reponse"""


def _ligne(r: dict, user_id: str) -> dict:
    return {
        "id": r["id"],
        "zoneId": r["zone_id"],
        "rue": r["rue"],
        "statut": r["statut"],
        "oui": r["oui"],
        "non": r["non"],
        "creeLe": r["cree_le"].isoformat(),
        "position": {"lon": r["lon"], "lat": r["lat"]} if r["lon"] is not None else None,
        "troncon": r["troncon"],
        "svg": r["svg"],
        "svgTroncon": r["svg_troncon"],
        "svgEtiquette": r["svg_etiquette"],
        "hauteurEau": r["hauteur_eau"],
        "description": r["description"],
        "distanceM": int(r["distance"]) if r["distance"] is not None else None,
        "maReponse": r["ma_reponse"],
        "estAuteur": r["auteur_id"] == user_id,
    }


def lire(db: psycopg.Connection, signalement_id: str, user_id: str, lat=None, lon=None) -> dict:
    r = db.execute(
        f"""SELECT {COLONNES} FROM signalement s
            LEFT JOIN confirmation c ON c.signalement_id = s.id AND c.utilisateur_id = %(uid)s
            WHERE s.id = %(id)s""",
        {"id": signalement_id, "uid": user_id, "lat": lat, "lon": lon},
    ).fetchone()
    if r is None:
        raise HTTPException(404, "Signalement inconnu")
    return _ligne(r, user_id)


@routeur.get("")
def liste(
    lat: float | None = Query(default=None, ge=-90, le=90),
    lon: float | None = Query(default=None, ge=-180, le=180),
    u: dict = Depends(utilisateur_courant),
    db: psycopg.Connection = Depends(get_db),
) -> list[dict]:
    """Signalements des 72 dernières heures ; avec lat/lon, distance à l'utilisateur (« Vous êtes à 140 m »)."""
    lignes = db.execute(
        f"""SELECT {COLONNES} FROM signalement s
            LEFT JOIN confirmation c ON c.signalement_id = s.id AND c.utilisateur_id = %(uid)s
            WHERE s.cree_le > now() - interval '{FENETRE}' ORDER BY s.cree_le DESC""",
        {"uid": u["id"], "lat": lat, "lon": lon},
    ).fetchall()
    return [_ligne(r, u["id"]) for r in lignes]


class NouveauSignalement(BaseModel):
    lat: float = Field(ge=-90, le=90)
    lon: float = Field(ge=-180, le=180)
    hauteurEau: Literal["Cheville", "Genou", "Taille"]
    rue: str | None = Field(default=None, max_length=120)
    description: str | None = Field(default=None, max_length=500)


@routeur.post("", status_code=201)
def creer(corps: NouveauSignalement, u: dict = Depends(utilisateur_courant), db: psycopg.Connection = Depends(get_db)) -> dict:
    """Signalement « À confirmer » ; l'auteur compte comme premier « oui »."""
    zone = db.execute(
        "SELECT id FROM zone WHERE ST_Covers(contour, ST_SetSRID(ST_MakePoint(%s, %s), 4326)::geography) LIMIT 1",
        (corps.lon, corps.lat),
    ).fetchone()
    if zone is None:
        raise HTTPException(422, "Ce point n'est pas dans un quartier suivi")
    nouveau = db.execute(
        """INSERT INTO signalement (zone_id, rue, hauteur_eau, description, position, auteur_id, oui)
           VALUES (%s, %s, %s, %s, ST_SetSRID(ST_MakePoint(%s, %s), 4326)::geography, %s, 1) RETURNING id""",
        (zone["id"], corps.rue, corps.hauteurEau, corps.description, corps.lon, corps.lat, u["id"]),
    ).fetchone()
    db.execute(
        """INSERT INTO confirmation (signalement_id, utilisateur_id, reponse, position)
           VALUES (%s, %s, 'oui', ST_SetSRID(ST_MakePoint(%s, %s), 4326)::geography)""",
        (nouveau["id"], u["id"], corps.lon, corps.lat),
    )
    db.commit()
    return lire(db, nouveau["id"], u["id"])


class Reponse(BaseModel):
    reponse: Literal["oui", "non", "inconnu"]
    lat: float | None = Field(default=None, ge=-90, le=90)
    lon: float | None = Field(default=None, ge=-180, le=180)


@routeur.post("/{signalement_id}/confirmations")
def confirmer(
    signalement_id: str, corps: Reponse, u: dict = Depends(utilisateur_courant), db: psycopg.Connection = Depends(get_db)
) -> dict:
    """« Oui » / « Non » / « Je ne sais pas » ; une réponse par habitant (modifiable)."""
    s = db.execute("SELECT auteur_id FROM signalement WHERE id = %s FOR UPDATE", (signalement_id,)).fetchone()
    if s is None:
        raise HTTPException(404, "Signalement inconnu")
    if s["auteur_id"] == u["id"]:
        raise HTTPException(409, "Vous êtes l'auteur de ce signalement")
    avant = db.execute(
        "SELECT reponse FROM confirmation WHERE signalement_id = %s AND utilisateur_id = %s",
        (signalement_id, u["id"]),
    ).fetchone()
    precedente = avant["reponse"] if avant else None
    point = (corps.lon, corps.lat) if corps.lat is not None and corps.lon is not None else (None, None)
    db.execute(
        """INSERT INTO confirmation (signalement_id, utilisateur_id, reponse, position)
           VALUES (%s, %s, %s, CASE WHEN %s::float8 IS NULL THEN NULL
                                    ELSE ST_SetSRID(ST_MakePoint(%s::float8, %s::float8), 4326)::geography END)
           ON CONFLICT (signalement_id, utilisateur_id) DO UPDATE SET reponse = EXCLUDED.reponse, cree_le = now()""",
        (signalement_id, u["id"], corps.reponse, point[0], point[0], point[1]),
    )
    d_oui = (corps.reponse == "oui") - (precedente == "oui")
    d_non = (corps.reponse == "non") - (precedente == "non")
    apres = db.execute(
        """UPDATE signalement SET oui = oui + %(o)s, non = non + %(n)s,
             statut = CASE WHEN oui + %(o)s >= %(seuil)s AND oui + %(o)s >= 3 * (non + %(n)s)
                           THEN 'CONFIRME'::statut_signalement ELSE statut END
           WHERE id = %(id)s RETURNING oui, non""",
        {"o": d_oui, "n": d_non, "seuil": SEUIL_CONFIRMATION, "id": signalement_id},
    ).fetchone()
    # Fiabilité : première réponse « oui » ou « non » qui rejoint (ou non) la majorité.
    if precedente is None and corps.reponse != "inconnu" and apres["oui"] != apres["non"]:
        majorite = "oui" if apres["oui"] > apres["non"] else "non"
        delta = BONUS_ACCORD if corps.reponse == majorite else -MALUS_DESACCORD
        db.execute(
            "UPDATE utilisateur SET score_fiabilite = least(%s, greatest(0, score_fiabilite + %s)) WHERE id = %s",
            (SCORE_MAX, delta, u["id"]),
        )
    db.commit()
    score = db.execute("SELECT score_fiabilite FROM utilisateur WHERE id = %s", (u["id"],)).fetchone()
    return {"signalement": lire(db, signalement_id, u["id"]), "scoreFiabilite": float(score["score_fiabilite"])}

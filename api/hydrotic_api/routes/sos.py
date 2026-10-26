"""SOS : envoi par un habitant (M4), suivi, prise en charge par les agents (D1, D3)."""
from typing import Literal

import psycopg
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field

from ..db import get_db
from ..utilisateurs import ROLES_AGENT, exiger_agent, nom_affiche, utilisateur_courant

routeur = APIRouter(prefix="/api", tags=["sos"])
ORDRE = ("RECU", "EN_ROUTE", "SECOURU")

COLONNES = """s.id, s.auteur_id, s.lieu, s.precision_m, s.svg_dashboard, s.nb_personnes, s.blesses, s.hauteur_eau,
  s.enfants_ou_ages, s.details, s.statut, s.canal_envoi, s.cree_le,
  ST_X(s.position::geometry) AS lon, ST_Y(s.position::geometry) AS lat"""


def _sos(db: psycopg.Connection, r: dict) -> dict:
    evenements = {
        e["statut"]: e
        for e in db.execute("SELECT statut, detail, cree_le FROM sos_evenement WHERE sos_id = %s", (r["id"],)).fetchall()
    }
    return {
        "id": r["id"],
        "lieu": r["lieu"],
        "position": {"lon": r["lon"], "lat": r["lat"]} if r["lon"] is not None else None,
        "precisionM": float(r["precision_m"]) if r["precision_m"] is not None else None,
        "svgDashboard": r["svg_dashboard"],
        "nbPersonnes": r["nb_personnes"],
        "blesses": r["blesses"],
        "hauteurEau": r["hauteur_eau"],
        "enfantsOuAges": r["enfants_ou_ages"],
        "details": r["details"],
        "statut": r["statut"],
        "canal": r["canal_envoi"],
        "creeLe": r["cree_le"].isoformat(),
        # Suivi : Reçu par les secours → Équipe en route → Secouru.
        "etapes": [
            {
                "statut": statut,
                "fait": ORDRE.index(r["statut"]) >= i,
                "detail": evenements[statut]["detail"] if statut in evenements else "",
                "le": evenements[statut]["cree_le"].isoformat() if statut in evenements else None,
            }
            for i, statut in enumerate(ORDRE)
        ],
    }


def _lire(db: psycopg.Connection, sos_id: str) -> dict:
    r = db.execute(f"SELECT {COLONNES} FROM sos s WHERE s.id = %s", (sos_id,)).fetchone()
    if r is None:
        raise HTTPException(404, "SOS inconnu")
    return r


class NouveauSos(BaseModel):
    lat: float | None = Field(default=None, ge=-90, le=90)
    lon: float | None = Field(default=None, ge=-180, le=180)
    precisionM: float | None = Field(default=None, ge=0, le=100_000)
    nbPersonnes: int = Field(default=1, ge=1, le=50)
    blesses: bool = False
    hauteurEau: Literal["Cheville", "Genou", "Taille"] | None = None
    enfantsOuAges: bool = False
    canal: Literal["internet", "sms"] = "internet"


@routeur.post("/sos", status_code=201)
def envoyer(corps: NouveauSos, u: dict = Depends(utilisateur_courant), db: psycopg.Connection = Depends(get_db)) -> dict:
    """SOS « Reçu » ; le lieu est le quartier si la position y tombe."""
    a_position = corps.lat is not None and corps.lon is not None
    zone = None
    if a_position:
        zone = db.execute(
            "SELECT nom FROM zone WHERE ST_Covers(contour, ST_SetSRID(ST_MakePoint(%s, %s), 4326)::geography) LIMIT 1",
            (corps.lon, corps.lat),
        ).fetchone()
    lieu = zone["nom"] if zone else ("Position GPS transmise" if a_position else "Position inconnue")
    details = ", ".join(
        d for d in ("Blessés" if corps.blesses else None, "Enfants / âgés" if corps.enfantsOuAges else None,
                    corps.hauteurEau and corps.hauteurEau.lower()) if d
    )
    nouveau = db.execute(
        """INSERT INTO sos (auteur_id, lieu, position, precision_m, nb_personnes, blesses, hauteur_eau,
                            enfants_ou_ages, details, canal_envoi)
           VALUES (%s, %s, CASE WHEN %s THEN ST_SetSRID(ST_MakePoint(%s::float8, %s::float8), 4326)::geography END,
                   %s, %s, %s, %s, %s, %s, %s)
           RETURNING id, to_char(cree_le, 'HH24:MI') AS heure""",
        (u["id"], lieu, a_position, corps.lon, corps.lat, corps.precisionM, corps.nbPersonnes, corps.blesses,
         corps.hauteurEau, corps.enfantsOuAges, details, corps.canal),
    ).fetchone()
    detail = (f"{nouveau['heure']} · position ± {round(corps.precisionM)} m transmise"
              if a_position and corps.precisionM is not None else f"{nouveau['heure']} · {lieu.lower()}")
    db.execute("INSERT INTO sos_evenement (sos_id, statut, detail) VALUES (%s, 'RECU', %s)", (nouveau["id"], detail))
    db.commit()
    return _sos(db, _lire(db, nouveau["id"]))


@routeur.get("/sos/{sos_id}")
def suivre(sos_id: str, u: dict = Depends(utilisateur_courant), db: psycopg.Connection = Depends(get_db)) -> dict:
    """Suivi d'un SOS : par son auteur ou par un agent."""
    r = _lire(db, sos_id)
    if r["auteur_id"] != u["id"] and u["role"] not in ROLES_AGENT:
        raise HTTPException(403, "Ce SOS ne vous appartient pas")
    return _sos(db, r)


@routeur.get("/agent/sos")
def liste(_agent: dict = Depends(exiger_agent), db: psycopg.Connection = Depends(get_db)) -> list[dict]:
    """SOS en cours et SOS des dernières 24 heures, les plus récents d'abord."""
    lignes = db.execute(
        f"""SELECT {COLONNES} FROM sos s
            WHERE s.statut <> 'SECOURU' OR s.cree_le > now() - interval '24 hours'
            ORDER BY s.cree_le DESC"""
    ).fetchall()
    return [_sos(db, r) for r in lignes]


class ChangementStatut(BaseModel):
    statut: Literal["EN_ROUTE", "SECOURU"]


@routeur.patch("/agent/sos/{sos_id}")
def avancer(
    sos_id: str, corps: ChangementStatut, agent: dict = Depends(exiger_agent), db: psycopg.Connection = Depends(get_db)
) -> dict:
    """Reçu → En route → Secouru (une étape à la fois)."""
    r = _lire(db, sos_id)
    if ORDRE.index(corps.statut) != ORDRE.index(r["statut"]) + 1:
        raise HTTPException(409, f"Le SOS est « {r['statut']} » : étape suivante attendue")
    heure = db.execute(
        "UPDATE sos SET statut = %s, pris_en_charge_par = %s WHERE id = %s RETURNING to_char(now(), 'HH24:MI') AS h",
        (corps.statut, agent["id"], sos_id),
    ).fetchone()["h"]
    equipe = " — ".join(p for p in (agent["service"], nom_affiche(agent)) if p)
    db.execute(
        "INSERT INTO sos_evenement (sos_id, statut, detail) VALUES (%s, %s, %s) ON CONFLICT DO NOTHING",
        (sos_id, corps.statut, f"{heure} · {equipe}" if equipe else heure),
    )
    db.commit()
    return _sos(db, _lire(db, sos_id))

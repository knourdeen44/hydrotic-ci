"""Alertes : diffusées aux habitants (M5) ; préparées, validées ou annulées par les agents (D1, D2, D6).

L'envoi réel (notifications, e-mails) arrive en phase 3 : « valider » passe l'alerte à « Envoyée ».
"""
from typing import Literal

import psycopg
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field

from ..db import get_db
from ..utilisateurs import exiger_agent

routeur = APIRouter(prefix="/api", tags=["alertes"])

COLONNES = """id, zone_id, niveau, titre, corps, statut, probabilite, signalements_confirmes, source, cree_le,
  validee_le, annulee_le"""


def _alerte(a: dict) -> dict:
    return {
        "id": a["id"],
        "zoneId": a["zone_id"],
        "niveau": a["niveau"],
        "titre": a["titre"],
        "corps": a["corps"],
        "statut": a["statut"],
        "probabilite": float(a["probabilite"]) if a["probabilite"] is not None else None,
        "signalementsConfirmes": a["signalements_confirmes"],
        "source": a["source"],
        "creeLe": a["cree_le"].isoformat(),
        "valideeLe": a["validee_le"].isoformat() if a["validee_le"] else None,
        "annuleeLe": a["annulee_le"].isoformat() if a["annulee_le"] else None,
    }


@routeur.get("/alertes")
def diffusees(db: psycopg.Connection = Depends(get_db)) -> list[dict]:
    """Alertes envoyées aux habitants, les plus récentes d'abord (sans connexion)."""
    lignes = db.execute(f"SELECT {COLONNES} FROM alerte WHERE statut = 'ENVOYEE' ORDER BY cree_le DESC").fetchall()
    return [_alerte(a) for a in lignes]


@routeur.get("/agent/alertes")
def toutes(_agent: dict = Depends(exiger_agent), db: psycopg.Connection = Depends(get_db)) -> list[dict]:
    """Toutes les alertes, y compris en attente de validation et annulées."""
    return [_alerte(a) for a in db.execute(f"SELECT {COLONNES} FROM alerte ORDER BY cree_le DESC").fetchall()]


@routeur.get("/agent/modeles")
def modeles(_agent: dict = Depends(exiger_agent), db: psycopg.Connection = Depends(get_db)) -> dict:
    """Modèles de messages (cahier des charges, section 11.5)."""
    return {m["cle"]: m["texte"] for m in db.execute("SELECT cle, texte FROM modele_message").fetchall()}


class NouvelleAlerte(BaseModel):
    zoneId: str
    niveau: Literal["vert", "jaune", "orange", "rouge"]
    corps: str | None = Field(default=None, max_length=600)


def _titre(niveau: str, zone: str) -> str:
    if niveau in ("orange", "rouge"):
        return f"ALERTE {niveau.upper()} — {zone}"
    if niveau == "jaune":
        return f"Vigilance jaune — {zone}"
    return f"Fin d'alerte — {zone}"


@routeur.post("/agent/alertes", status_code=201)
def preparer(corps: NouvelleAlerte, agent: dict = Depends(exiger_agent), db: psycopg.Connection = Depends(get_db)) -> dict:
    """Alerte manuelle « En attente » ; message par défaut tiré des modèles."""
    zone = db.execute("SELECT nom FROM zone WHERE id = %s", (corps.zoneId,)).fetchone()
    if zone is None:
        raise HTTPException(404, "Zone inconnue")
    texte = corps.corps
    if not texte:
        cle = {"vert": "finAlerte", "orange": "orange", "rouge": "rouge"}.get(corps.niveau)
        modele = db.execute("SELECT texte FROM modele_message WHERE cle = %s", (cle,)).fetchone() if cle else None
        # Pas de modèle pour la vigilance jaune : texte de l'alerte al-3 des données de départ.
        texte = modele["texte"].replace("[quartier]", zone["nom"]) if modele else f"Vigilance jaune pour demain à {zone['nom']}."
    a = db.execute(
        f"""INSERT INTO alerte (zone_id, niveau, titre, corps, source) VALUES (%s, %s, %s, %s, %s)
            RETURNING {COLONNES}""",
        (corps.zoneId, corps.niveau, _titre(corps.niveau, zone["nom"]), texte, f"Saisie agent — {agent['service'] or 'ONPC'}"),
    ).fetchone()
    db.commit()
    return _alerte(a)


def _changer(db: psycopg.Connection, alerte_id: str, requete: str, agent_id: str) -> dict:
    statut = db.execute("SELECT statut FROM alerte WHERE id = %s FOR UPDATE", (alerte_id,)).fetchone()
    if statut is None:
        raise HTTPException(404, "Alerte inconnue")
    if statut["statut"] != "EN_ATTENTE":
        raise HTTPException(409, "Seule une alerte en attente peut être validée ou annulée")
    a = db.execute(requete + f" WHERE id = %s RETURNING {COLONNES}", (agent_id, alerte_id)).fetchone()
    db.commit()
    return _alerte(a)


@routeur.post("/agent/alertes/{alerte_id}/valider")
def valider(alerte_id: str, agent: dict = Depends(exiger_agent), db: psycopg.Connection = Depends(get_db)) -> dict:
    """« Valider et envoyer » : l'alerte devient visible des habitants (envoi réel en phase 3)."""
    return _changer(db, alerte_id, "UPDATE alerte SET statut = 'ENVOYEE', validee_par = %s, validee_le = now()", agent["id"])


@routeur.post("/agent/alertes/{alerte_id}/annuler")
def annuler(alerte_id: str, agent: dict = Depends(exiger_agent), db: psycopg.Connection = Depends(get_db)) -> dict:
    return _changer(db, alerte_id, "UPDATE alerte SET statut = 'ANNULEE', annulee_par = %s, annulee_le = now()", agent["id"])

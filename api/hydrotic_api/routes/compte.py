"""Compte de l'utilisateur connecté : profil, quartiers suivis, canaux d'alerte."""
from typing import Literal

import psycopg
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field

from ..db import get_db
from ..utilisateurs import utilisateur_courant

routeur = APIRouter(prefix="/api/moi", tags=["compte"])


def profil(db: psycopg.Connection, user_id: str) -> dict:
    u = db.execute(
        """SELECT u.*, coalesce(array_agg(zs.zone_id ORDER BY zs.zone_id DESC)
                         FILTER (WHERE zs.zone_id IS NOT NULL), '{}') AS zones_suivies
           FROM utilisateur u LEFT JOIN zone_suivie zs ON zs.utilisateur_id = u.id
           WHERE u.id = %s GROUP BY u.id""",
        (user_id,),
    ).fetchone()
    return {
        "id": u["id"],
        "nom": u["prenom"] or u["nom"] or "",
        "prenom": u["prenom"],
        "nomFamille": u["nom"],
        "email": u["email"],
        "role": u["role"],
        "service": u["service"],
        "scoreFiabilite": float(u["score_fiabilite"]),
        "canauxPreferes": u["canaux"],
        "zonesSuivies": u["zones_suivies"],
    }


class ModificationProfil(BaseModel):
    prenom: str | None = Field(default=None, max_length=60)
    zonesSuivies: list[str] | None = Field(default=None, max_length=10)
    canauxPreferes: list[Literal["push", "email"]] | None = None


@routeur.get("")
def moi(u: dict = Depends(utilisateur_courant), db: psycopg.Connection = Depends(get_db)) -> dict:
    """Profil (compte citoyen créé à la première connexion)."""
    return profil(db, u["id"])


@routeur.patch("")
def modifier(
    corps: ModificationProfil, u: dict = Depends(utilisateur_courant), db: psycopg.Connection = Depends(get_db)
) -> dict:
    """Prénom, quartiers suivis (M0 étape 3, M6 « Modifier »), canaux d'alerte (M6)."""
    if corps.prenom is not None:
        db.execute("UPDATE utilisateur SET prenom = %s WHERE id = %s", (corps.prenom.strip() or None, u["id"]))
    if corps.canauxPreferes is not None:
        db.execute("UPDATE utilisateur SET canaux = %s WHERE id = %s", (sorted(set(corps.canauxPreferes)), u["id"]))
    if corps.zonesSuivies is not None:
        connues = {z["id"] for z in db.execute("SELECT id FROM zone").fetchall()}
        if not corps.zonesSuivies or not set(corps.zonesSuivies) <= connues:
            raise HTTPException(422, "Choisissez au moins un quartier parmi les quartiers suivis")
        db.execute("DELETE FROM zone_suivie WHERE utilisateur_id = %s", (u["id"],))
        for zone_id in dict.fromkeys(corps.zonesSuivies):
            db.execute("INSERT INTO zone_suivie (utilisateur_id, zone_id) VALUES (%s, %s)", (u["id"], zone_id))
    db.commit()
    return profil(db, u["id"])

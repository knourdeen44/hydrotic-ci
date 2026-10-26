"""Administration : comptes et rôles (promotion des agents ONPC et mairies)."""
from typing import Literal

import psycopg
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field

from ..db import get_db
from ..utilisateurs import exiger_admin

routeur = APIRouter(prefix="/api/admin", tags=["administration"])


def _compte(u: dict) -> dict:
    return {
        "id": u["id"],
        "prenom": u["prenom"],
        "nom": u["nom"],
        "email": u["email"],
        "role": u["role"],
        "service": u["service"],
        "creeLe": u["cree_le"].isoformat(),
    }


@routeur.get("/utilisateurs")
def comptes(_admin: dict = Depends(exiger_admin), db: psycopg.Connection = Depends(get_db)) -> list[dict]:
    lignes = db.execute(
        "SELECT * FROM utilisateur ORDER BY (role = 'CITOYEN'), lower(coalesce(email, id))"
    ).fetchall()
    return [_compte(u) for u in lignes]


class ChangementRole(BaseModel):
    role: Literal["CITOYEN", "AGENT", "ADMIN"]
    service: str | None = Field(default=None, max_length=80)


@routeur.patch("/utilisateurs/{user_id}")
def changer_role(
    user_id: str, corps: ChangementRole, admin: dict = Depends(exiger_admin), db: psycopg.Connection = Depends(get_db)
) -> dict:
    """Rôle et service (ex. « ONPC Abidjan Sud ») d'un compte existant."""
    if user_id == admin["id"] and corps.role != "ADMIN":
        raise HTTPException(409, "Un administrateur ne peut pas retirer son propre rôle")
    u = db.execute(
        "UPDATE utilisateur SET role = %s, service = coalesce(%s, service) WHERE id = %s RETURNING *",
        (corps.role, corps.service, user_id),
    ).fetchone()
    if u is None:
        raise HTTPException(404, "Compte inconnu (la personne doit s'être connectée une fois)")
    db.commit()
    return _compte(u)

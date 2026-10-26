"""Utilisateurs : profil complété depuis Clerk, rôles (citoyen, agent, administrateur).

Un compte est créé comme citoyen à la première connexion. Les adresses de ADMIN_EMAILS deviennent
administrateurs ; un administrateur promeut ensuite les agents (ONPC, mairies).
"""
import os

import httpx
import psycopg
from fastapi import Depends, HTTPException, status

from .auth import utilisateur_connecte
from .db import get_db

CLERK_API = "https://api.clerk.com/v1"
ROLES_AGENT = ("AGENT", "ADMIN")


def profil_clerk(user_id: str) -> dict | None:
    """Prénom, nom et e-mail principal (API Clerk ; None si la clé secrète manque ou si Clerk ne répond pas)."""
    cle = os.environ.get("CLERK_SECRET_KEY")
    if not cle:
        return None
    try:
        r = httpx.get(f"{CLERK_API}/users/{user_id}", headers={"Authorization": f"Bearer {cle}"}, timeout=5)
        r.raise_for_status()
    except httpx.HTTPError:
        return None
    u = r.json()
    adresses = u.get("email_addresses") or []
    principale = next((a for a in adresses if a.get("id") == u.get("primary_email_address_id")), None)
    email = (principale or (adresses[0] if adresses else {})).get("email_address")
    return {"prenom": u.get("first_name"), "nom": u.get("last_name"), "email": email}


def emails_admin() -> set[str]:
    return {e.strip().lower() for e in os.environ.get("ADMIN_EMAILS", "").split(",") if e.strip()}


def _lire(db: psycopg.Connection, user_id: str) -> dict | None:
    return db.execute("SELECT * FROM utilisateur WHERE id = %s", (user_id,)).fetchone()


def utilisateur_courant(jeton: dict = Depends(utilisateur_connecte), db: psycopg.Connection = Depends(get_db)) -> dict:
    """Dépendance : ligne `utilisateur` du compte connecté, créée ou complétée si besoin."""
    user_id = jeton["sub"]
    u = _lire(db, user_id)
    if u is None or u["email"] is None:
        profil = profil_clerk(user_id) or {}
        admin = (profil.get("email") or "").lower() in emails_admin()
        db.execute(
            """INSERT INTO utilisateur (id, prenom, nom, email, role)
               VALUES (%(id)s, %(prenom)s, %(nom)s, %(email)s, CASE WHEN %(admin)s THEN 'ADMIN' ELSE 'CITOYEN' END::role_utilisateur)
               ON CONFLICT (id) DO UPDATE SET
                 prenom = coalesce(utilisateur.prenom, EXCLUDED.prenom),
                 nom = coalesce(utilisateur.nom, EXCLUDED.nom),
                 email = coalesce(utilisateur.email, EXCLUDED.email),
                 role = CASE WHEN %(admin)s THEN 'ADMIN'::role_utilisateur ELSE utilisateur.role END""",
            {"id": user_id, "admin": admin, **{k: profil.get(k) for k in ("prenom", "nom", "email")}},
        )
        db.commit()
        u = _lire(db, user_id)
    return u


def exiger_agent(u: dict = Depends(utilisateur_courant)) -> dict:
    if u["role"] not in ROLES_AGENT:
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Réservé aux agents (ONPC, mairies)")
    return u


def exiger_admin(u: dict = Depends(utilisateur_courant)) -> dict:
    if u["role"] != "ADMIN":
        raise HTTPException(status.HTTP_403_FORBIDDEN, "Réservé aux administrateurs")
    return u


def nom_affiche(u: dict) -> str:
    return " ".join(p for p in (u.get("prenom"), u.get("nom")) if p) or (u.get("email") or "")

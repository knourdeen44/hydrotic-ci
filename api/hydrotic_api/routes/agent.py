"""Espace agents : niveaux de risque saisis, indicateurs du tableau de bord (D1)."""
from datetime import date, datetime, timedelta, timezone
from typing import Literal

import psycopg
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel

from ..db import get_db
from ..utilisateurs import exiger_agent, nom_affiche
from .public import niveau_du_jour

routeur = APIRouter(prefix="/api/agent", tags=["agents"])
FENETRE_SIGNALEMENTS_H = 2


class Prevision(BaseModel):
    zoneId: str
    jour: date
    niveau: Literal["vert", "jaune", "orange", "rouge"]
    probabilite: float | None = None


@routeur.put("/previsions")
def fixer_niveau(corps: Prevision, agent: dict = Depends(exiger_agent), db: psycopg.Connection = Depends(get_db)) -> dict:
    """Niveau de risque d'une zone pour un jour (pas de modèle de prévision avant la phase 4)."""
    if db.execute("SELECT 1 FROM zone WHERE id = %s", (corps.zoneId,)).fetchone() is None:
        raise HTTPException(404, "Zone inconnue")
    p = db.execute(
        """INSERT INTO prevision (zone_id, jour, niveau, probabilite, version_modele, maj_le, maj_par)
           VALUES (%s, %s, %s, %s, 'saisie agent', now(), %s)
           ON CONFLICT (zone_id, jour) DO UPDATE SET niveau = EXCLUDED.niveau, probabilite = EXCLUDED.probabilite,
             version_modele = EXCLUDED.version_modele, maj_le = now(), maj_par = EXCLUDED.maj_par
           RETURNING zone_id, jour, niveau, maj_le""",
        (corps.zoneId, corps.jour, corps.niveau, corps.probabilite, agent["id"]),
    ).fetchone()
    db.commit()
    return {"zoneId": p["zone_id"], "jour": p["jour"].isoformat(), "niveau": p["niveau"], "majLe": p["maj_le"].isoformat()}


@routeur.get("/tableau")
def tableau(agent: dict = Depends(exiger_agent), db: psycopg.Connection = Depends(get_db)) -> dict:
    """Chiffres de la vue d'ensemble (la mise en forme des textes reste côté tableau de bord)."""
    maintenant = datetime.now(timezone.utc)
    zones = [z["id"] for z in db.execute("SELECT id FROM zone").fetchall()]
    niveaux = {}
    for zone_id in zones:
        # Niveau retenu : le plus élevé entre aujourd'hui et demain.
        jours = [niveau_du_jour(db, zone_id, maintenant.date() + timedelta(days=d)) for d in (0, 1)]
        connus = [j["niveau"] for j in jours if j]
        niveaux[zone_id] = max(connus, key=("vert", "jaune", "orange", "rouge").index) if connus else "vert"
    en_alerte = {z: n for z, n in niveaux.items() if n in ("orange", "rouge")}
    sos = db.execute(
        """SELECT count(*) FILTER (WHERE statut <> 'SECOURU') AS actifs,
                  count(*) FILTER (WHERE statut = 'RECU') AS non_pris
           FROM sos""",
    ).fetchone()
    signalements = db.execute(
        f"""SELECT count(*) FILTER (WHERE statut = 'CONFIRME') AS confirmes, count(*) AS recus
            FROM signalement WHERE cree_le > now() - interval '{FENETRE_SIGNALEMENTS_H} hours'""",
    ).fetchone()
    attente = db.execute("SELECT count(*) AS n FROM alerte WHERE statut = 'EN_ATTENTE'").fetchone()["n"]
    return {
        "majLe": maintenant.isoformat(),
        "agent": {"nom": nom_affiche(agent), "service": agent["service"]},
        "zonesEnAlerte": {
            "n": len(en_alerte),
            "total": len(zones),
            "parNiveau": {n: list(en_alerte.values()).count(n) for n in ("rouge", "orange")},
        },
        "sos": {"actifs": sos["actifs"], "nonPrisEnCharge": sos["non_pris"]},
        "signalements": {"confirmes": signalements["confirmes"], "recus": signalements["recus"],
                         "fenetreHeures": FENETRE_SIGNALEMENTS_H},
        # Taux de remise des alertes : connu quand l'envoi réel existera (phase 3).
        "alertesDelivrees": None,
        "badges": {"alertes": attente, "sos": sos["non_pris"]},
    }

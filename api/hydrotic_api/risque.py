"""Moteur de risque sans capteurs (cahier des charges §4.6, version à seuils, sans modèle d'IA).

Niveau affiché = le plus élevé entre :
  - la prévision calculée depuis la pluie Open-Meteo (pluie du jour + pluie des 2 jours précédents, sol saturé) ;
  - le niveau saisi par un agent ;
  - le terrain : au moins SIGNALEMENTS_ORANGE signalements confirmés dans l'heure → au moins orange.
Le rouge n'est jamais donné par le calcul seul : il est proposé aux agents (« rougeAValider »), qui le valident.
Un SOS actif dans une zone la met en rouge sur le tableau de bord des autorités seulement.
Toutes les valeurs sont des valeurs de départ, à calibrer avec l'historique, la SODEXAM et l'ONPC.
"""
from datetime import date, datetime, timedelta, timezone

import psycopg

from .pluie import PluieIndisponible, pluie_zone

NIVEAUX = ("vert", "jaune", "orange", "rouge")
VERSION = "seuils-v1"
# Probabilité à partir de laquelle on passe en jaune, orange, rouge (<20 %, 20-40 %, 40-70 %, >70 %).
SEUILS = (0.20, 0.40, 0.70)
# Poids de la pluie du jour, de la veille et de l'avant-veille (un sol déjà mouillé absorbe moins).
POIDS = (1.0, 0.5, 0.25)
# Indice de pluie (mm pondérés) correspondant à une probabilité de 100 %.
PLUIE_REFERENCE_MM = 100.0
SIGNALEMENTS_ORANGE = 3


def plus_eleve(*niveaux: str | None) -> str:
    return max((n for n in niveaux if n), key=NIVEAUX.index, default="vert")


def indice_pluie(mm_par_jour: dict[date, float], jour: date) -> float:
    return sum(poids * mm_par_jour.get(jour - timedelta(days=i), 0.0) for i, poids in enumerate(POIDS))


def probabilite(indice: float) -> float:
    return round(min(1.0, max(0.0, indice / PLUIE_REFERENCE_MM)), 2)


def niveau_de(probabilite_: float) -> str:
    return NIVEAUX[sum(probabilite_ >= s for s in SEUILS)]


def prevision_pluie(mm_par_jour: dict[date, float], jour: date) -> dict:
    """Prévision calculée pour un jour ; le rouge est seulement proposé (plafonné à orange)."""
    p = probabilite(indice_pluie(mm_par_jour, jour))
    brut = niveau_de(p)
    return {
        "probabilite": p,
        "niveau": "orange" if brut == "rouge" else brut,
        "rougeAValider": brut == "rouge",
    }


def _niveau_agent(db: psycopg.Connection, zone_id: str, jour: date) -> str | None:
    ligne = db.execute(
        "SELECT niveau FROM prevision WHERE zone_id = %s AND jour <= %s ORDER BY jour DESC LIMIT 1",
        (zone_id, jour),
    ).fetchone()
    return ligne["niveau"] if ligne else None


def _confirmes_dans_l_heure(db: psycopg.Connection, zone_id: str) -> int:
    """Signalements confirmés créés ou reconfirmés (« oui ») dans la dernière heure."""
    return db.execute(
        """SELECT count(*) AS n FROM signalement s
           WHERE s.zone_id = %s AND s.statut = 'CONFIRME'
             AND (s.cree_le > now() - interval '1 hour'
                  OR EXISTS (SELECT 1 FROM confirmation c WHERE c.signalement_id = s.id
                             AND c.reponse = 'oui' AND c.cree_le > now() - interval '1 hour'))""",
        (zone_id,),
    ).fetchone()["n"]


def sos_actifs(db: psycopg.Connection, zone_id: str) -> int:
    """SOS non secourus dont la position est dans le contour de la zone."""
    return db.execute(
        """SELECT count(*) AS n FROM sos s JOIN zone z ON z.id = %s
           WHERE s.statut <> 'SECOURU' AND s.position IS NOT NULL
             AND ST_Within(s.position::geometry, z.contour::geometry)""",
        (zone_id,),
    ).fetchone()["n"]


def risque_zone(db: psycopg.Connection, zone_id: str, maintenant: datetime | None = None) -> dict:
    """Niveau d'aujourd'hui et de demain, avec le détail de chaque source."""
    maintenant = maintenant or datetime.now(timezone.utc)
    aujourdhui, demain = maintenant.date(), maintenant.date() + timedelta(days=1)

    try:
        pluie = pluie_zone(db, zone_id, maintenant)
        mm = {date.fromisoformat(j["jour"]): j["mm"] for j in pluie["jours"]}
        calcul = {"aujourdhui": prevision_pluie(mm, aujourdhui), "demain": prevision_pluie(mm, demain)}
    except PluieIndisponible:
        calcul = None  # Open-Meteo et cache indisponibles : le niveau repose sur les agents et le terrain.

    agent = {"aujourdhui": _niveau_agent(db, zone_id, aujourdhui), "demain": _niveau_agent(db, zone_id, demain)}
    confirmes = _confirmes_dans_l_heure(db, zone_id)
    terrain = "orange" if confirmes >= SIGNALEMENTS_ORANGE else None

    def calcule(cle: str) -> str | None:
        return calcul[cle]["niveau"] if calcul else None

    return {
        "aujourdhui": plus_eleve(calcule("aujourdhui"), agent["aujourdhui"], terrain),
        "demain": plus_eleve(calcule("demain"), agent["demain"]),
        "rougeAValider": bool(calcul) and any(
            calcul[c]["rougeAValider"] and agent[c] != "rouge" for c in ("aujourdhui", "demain")
        ),
        "sources": {
            "calcul": calcul and {**calcul, "version": VERSION},
            "agent": agent,
            "terrain": {"confirmesDerniereHeure": confirmes, "seuil": SIGNALEMENTS_ORANGE, "niveau": terrain},
        },
    }

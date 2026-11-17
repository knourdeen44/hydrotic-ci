"""Moteur de risque à seuils : pluie Open-Meteo, saisie des agents, terrain (cahier des charges §4.6)."""
from datetime import date, datetime, timedelta, timezone

import psycopg
import pytest

from conftest import URL, jeton
from hydrotic_api import pluie
from hydrotic_api.risque import niveau_de, plus_eleve, prevision_pluie


def test_seuils_de_probabilite():
    assert [niveau_de(p) for p in (0, 0.19, 0.2, 0.39, 0.4, 0.69, 0.7, 1)] == [
        "vert", "vert", "jaune", "jaune", "orange", "orange", "rouge", "rouge"]


def test_le_plus_eleve_l_emporte():
    assert plus_eleve(None, "jaune", "orange") == "orange"
    assert plus_eleve(None, None) == "vert"


def test_sol_sature_et_rouge_seulement_propose():
    j = date(2026, 6, 17)
    # 30 mm aujourd'hui seuls : jaune ; avec 40 mm la veille et 20 mm l'avant-veille : 30 + 20 + 5 = 55 → orange.
    assert prevision_pluie({j: 30}, j)["niveau"] == "jaune"
    assert prevision_pluie({j: 30, j - timedelta(days=1): 40, j - timedelta(days=2): 20}, j)["probabilite"] == 0.55
    tres_forte = prevision_pluie({j: 90}, j)
    assert (tres_forte["niveau"], tres_forte["rougeAValider"]) == ("orange", True)


@pytest.fixture
def base():
    with psycopg.connect(URL, row_factory=psycopg.rows.dict_row) as c:
        c.execute("DELETE FROM observation")
        yield c
        c.execute("DELETE FROM observation")
        c.execute("DELETE FROM signalement WHERE id LIKE 'moteur-%'")


def test_forte_pluie_prevue_demain(client, monkeypatch, base):
    aujourdhui = datetime.now(timezone.utc).date()
    pluies = {aujourdhui + timedelta(days=1): 95.0}
    monkeypatch.setattr(pluie, "_interroger", lambda _lat, _lon: [
        (aujourdhui + timedelta(days=d), pluies.get(aujourdhui + timedelta(days=d), 0.0)) for d in range(-4, 3)])

    r = client.get("/api/zones/palmeraie/risque").json()
    assert r["demain"] == "orange"  # plafonné : le rouge attend un agent
    assert r["rougeAValider"] is True
    assert r["sources"]["calcul"]["demain"]["probabilite"] == 0.95

    base.execute(
        """INSERT INTO utilisateur (id, role, prenom) VALUES ('user_moteur', 'AGENT', 'Agent')
           ON CONFLICT (id) DO UPDATE SET role = 'AGENT'""")
    base.commit()
    t = client.get("/api/agent/tableau", headers={"Authorization": f"Bearer {jeton('user_moteur')}"})
    assert "palmeraie" in t.json()["zonesEnAlerte"]["rougeAValider"]


def test_signalements_confirmes_dans_l_heure(client, base):
    avant = client.get("/api/zones/treichville/risque").json()
    assert avant["sources"]["calcul"] is None  # Open-Meteo en panne et cache vide
    for i in range(3):
        base.execute(
            "INSERT INTO signalement (id, zone_id, rue, statut) VALUES (%s, 'treichville', 'Avenue 21', 'CONFIRME')",
            (f"moteur-{i}",),
        )
    base.commit()
    r = client.get("/api/zones/treichville/risque").json()
    assert r["sources"]["terrain"]["confirmesDerniereHeure"] >= 3
    assert r["aujourdhui"] in ("orange", "rouge")

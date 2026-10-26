import psycopg

from conftest import URL, jeton
from hydrotic_api.migrate import migrer
from hydrotic_api.seed import date_fixture, peupler


def test_sante(client):
    r = client.get("/api/sante")
    assert r.status_code == 200
    assert r.json()["statut"] == "ok"
    assert r.json()["zones"] == 2
    assert r.json()["postgis"]


def test_migrations_et_donnees_idempotentes():
    with psycopg.connect(URL, row_factory=psycopg.rows.dict_row) as c:
        assert migrer(c) == []
        peupler(c)
        assert c.execute("SELECT count(*) AS n FROM alerte").fetchone()["n"] == 3
        assert c.execute("SELECT count(*) AS n FROM sos").fetchone()["n"] == 4
        assert c.execute("SELECT count(*) AS n FROM consigne WHERE niveau = 'orange'").fetchone()["n"] == 3


def test_date_des_fixtures():
    d = date_fixture("Mercredi 17 juin · 18:42")
    assert (d.year, d.month, d.day, d.hour, d.minute) == (2026, 6, 17, 18, 42)
    assert d.weekday() == 2  # mercredi


def test_zones(client):
    zones = client.get("/api/zones").json()
    assert [z["nom"] for z in zones] == ["Treichville", "Riviera Palmeraie"]
    assert zones[1]["commune"] == "Cocody"
    assert zones[0]["sousZones"][0] == "Avenue 21"


def test_moi_sans_jeton(client):
    assert client.get("/api/moi").status_code == 401


def test_moi_jeton_invalide(client):
    assert client.get("/api/moi", headers={"Authorization": "Bearer pas-un-jwt"}).status_code == 401


def test_moi_jeton_expire(client):
    r = client.get("/api/moi", headers={"Authorization": f"Bearer {jeton(expire_dans=-60)}"})
    assert r.status_code == 401


def test_moi_origine_non_autorisee(client):
    r = client.get("/api/moi", headers={"Authorization": f"Bearer {jeton(azp='https://ailleurs.example')}"})
    assert r.status_code == 401


def test_moi_cree_un_citoyen(client):
    r = client.get("/api/moi", headers={"Authorization": f"Bearer {jeton('user_awa')}"})
    assert r.status_code == 200
    assert r.json()["role"] == "CITOYEN"
    assert r.json()["zonesSuivies"] == []
    # Seconde connexion : même compte, pas de doublon.
    assert client.get("/api/moi", headers={"Authorization": f"Bearer {jeton('user_awa')}"}).json()["id"] == "user_awa"

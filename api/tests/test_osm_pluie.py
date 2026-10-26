from datetime import date, datetime, timedelta, timezone

import httpx
import psycopg
import pytest

from conftest import URL
from hydrotic_api import pluie
from hydrotic_api.pluie import PluieIndisponible, libelle, pluie_zone

MAINTENANT = datetime(2026, 10, 26, 9, 0, tzinfo=timezone.utc)


def _db():
    return psycopg.connect(URL, row_factory=psycopg.rows.dict_row)


def test_contours_et_positions_osm_dans_leur_quartier():
    with _db() as c:
        zones = c.execute("SELECT id, ST_GeometryType(contour::geometry) AS t, ST_Area(contour) / 1e6 AS km2 FROM zone").fetchall()
        assert {z["id"]: z["t"] for z in zones} == {"treichville": "ST_MultiPolygon", "palmeraie": "ST_MultiPolygon"}
        # Treichville : contour administratif OSM ≈ 14,7 km² (lagune et zone portuaire comprises) ;
        # Riviera Palmeraie : zone résidentielle de quelques km².
        aires = {z["id"]: z["km2"] for z in zones}
        assert 10 < aires["treichville"] < 20 and 0.5 < aires["palmeraie"] < 5
        hors = c.execute(
            """SELECT s.id FROM signalement s JOIN zone z ON z.id = s.zone_id
               WHERE NOT ST_Within(s.position::geometry, z.contour::geometry)"""
        ).fetchall()
        assert hors == []
        assert c.execute("SELECT count(*) AS n FROM sos WHERE position IS NULL").fetchone()["n"] == 0
        troncon = c.execute("SELECT ST_Length(troncon) AS m FROM signalement WHERE id = 'sg-1'").fetchone()["m"]
        assert 50 < troncon < 600


def test_zones_avec_contour_geojson(client):
    zones = client.get("/api/zones").json()
    treichville = zones[0]
    assert treichville["contour"]["type"] == "MultiPolygon"
    lon, lat = treichville["centre"]
    assert -4.04 < lon < -3.99 and 5.26 < lat < 5.32


def test_libelles():
    assert [libelle(d) for d in range(-4, 3)] == ["J-4", "J-3", "J-2", "J-1", "Auj.", "J+1", "J+2"]


def _faux_open_meteo(appels):
    def interroger(lat, lon):
        appels.append((lat, lon))
        debut = MAINTENANT.date() - timedelta(days=4)
        return [(debut + timedelta(days=i), mm) for i, mm in enumerate([0.3, 1.0, 2.2, 0.5, 2.3, 13.6, 13.2])]
    return interroger


def test_pluie_open_meteo_puis_cache(monkeypatch):
    appels = []
    monkeypatch.setattr(pluie, "_interroger", _faux_open_meteo(appels))
    with _db() as c:
        c.execute("DELETE FROM observation")
        c.commit()
        r = pluie_zone(c, "treichville", MAINTENANT)
        assert [j["label"] for j in r["jours"]] == ["J-4", "J-3", "J-2", "J-1", "Auj.", "J+1", "J+2"]
        assert [j["prevision"] for j in r["jours"]] == [False] * 5 + [True] * 2
        assert r["jours"][5]["mm"] == 13.6
        assert "Open-Meteo" in r["attribution"]
        # Seconde demande dans l'heure : cache, pas d'appel.
        pluie_zone(c, "treichville", MAINTENANT + timedelta(minutes=30))
        assert len(appels) == 1
        # Après une heure : nouvel appel.
        pluie_zone(c, "treichville", MAINTENANT + timedelta(minutes=61))
        assert len(appels) == 2


def test_pluie_sans_reseau_garde_le_cache(monkeypatch):
    def en_panne(lat, lon):
        raise httpx.ConnectError("hors ligne")
    monkeypatch.setattr(pluie, "_interroger", en_panne)
    with _db() as c:
        r = pluie_zone(c, "treichville", MAINTENANT + timedelta(hours=3))
        assert len(r["jours"]) == 7
        c.execute("DELETE FROM observation WHERE zone_id = 'palmeraie'")
        c.commit()
        with pytest.raises(PluieIndisponible):
            pluie_zone(c, "palmeraie", MAINTENANT)


def test_point_d_acces_pluie(client, monkeypatch):
    monkeypatch.setattr(pluie, "_interroger", _faux_open_meteo([]))
    monkeypatch.setattr(pluie, "datetime", type("D", (), {"now": staticmethod(lambda tz=None: MAINTENANT)}))
    r = client.get("/api/zones/palmeraie/pluie")
    assert r.status_code == 200
    assert len(r.json()["jours"]) == 7
    assert client.get("/api/zones/inconnue/pluie").status_code == 404


def test_date_du_jour_abidjan():
    assert MAINTENANT.date() == date(2026, 10, 26)

"""Importe une fois les géométries réelles depuis OpenStreetMap (Nominatim) et les enregistre dans
hydrotic_api/donnees/osm.geojson (versionné). L'API ne contacte jamais OSM à l'exécution.

Données © contributeurs OpenStreetMap, licence ODbL (https://www.openstreetmap.org/copyright).
Charte Nominatim : une requête par seconde au plus, User-Agent identifiable.

Usage : uv run python outils/importer_osm.py
"""
import json
import time
from pathlib import Path

import httpx

SORTIE = Path(__file__).resolve().parents[1] / "hydrotic_api" / "donnees" / "osm.geojson"
UA = {"User-Agent": "HydroticCI/0.2 (prototype prevention inondations; github.com/knourdeen44/hydrotic-ci)"}
NOMINATIM = "https://nominatim.openstreetmap.org"

ZONES = {"treichville": "R3308305", "palmeraie": "R4600705"}  # commune ; zone résidentielle
RUE_MINISTRE = 328840073       # avenue Albert Kakou Tiapani, appelée « Rue Ministre » (commerces OSM)
PHARMACIE_RUE_MINISTRE = (-3.95786, 5.36523)
ARRET_AVENUE_21 = (-4.00653, 5.30286)  # nœud 10556842060, arrêt de bus « Avenue 21 »


def _get(chemin: str, **params) -> list[dict]:
    r = httpx.get(f"{NOMINATIM}/{chemin}", params={"format": "json", **params}, headers=UA, timeout=30)
    r.raise_for_status()
    time.sleep(1.1)
    return r.json()


def _anneaux(geometrie: dict) -> list[list[list[float]]]:
    """Anneaux extérieurs d'un Polygon ou d'un MultiPolygon."""
    if geometrie["type"] == "Polygon":
        return [geometrie["coordinates"][0]]
    return [polygone[0] for polygone in geometrie["coordinates"]]


def _dedans(point: tuple[float, float], geometrie: dict) -> bool:
    """Point dans le polygone (lancer de rayon sur les anneaux extérieurs)."""
    x, y = point
    dedans = False
    for anneau in _anneaux(geometrie):
        for (x1, y1), (x2, y2) in zip(anneau, anneau[1:]):
            if (y1 > y) != (y2 > y) and x < (x2 - x1) * (y - y1) / (y2 - y1) + x1:
                dedans = not dedans
    return dedans


def _point_interieur(geometrie: dict, decalage: tuple[float, float]) -> tuple[float, float]:
    """Point intérieur près du centre des sommets, déplacé de [decalage] (degrés) si possible."""
    sommets = [p for anneau in _anneaux(geometrie) for p in anneau]
    cx = sum(p[0] for p in sommets) / len(sommets)
    cy = sum(p[1] for p in sommets) / len(sommets)
    for facteur in (1, 0.5, 0.25, 0):
        candidat = (round(cx + decalage[0] * facteur, 5), round(cy + decalage[1] * facteur, 5))
        if _dedans(candidat, geometrie):
            return candidat
    raise ValueError("aucun point intérieur trouvé")


def _plus_proche(ligne: list[list[float]], point: tuple[float, float]) -> int:
    return min(range(len(ligne)), key=lambda i: (ligne[i][0] - point[0]) ** 2 + (ligne[i][1] - point[1]) ** 2)


def _entite(geometrie: dict, **proprietes) -> dict:
    if geometrie["type"] == "Point":
        geometrie = {"type": "Point", "coordinates": [round(c, 6) for c in geometrie["coordinates"]]}
    return {"type": "Feature", "geometry": geometrie, "properties": proprietes}


def importer() -> dict:
    contours = {
        x["osm_id"]: x["geojson"]
        for x in _get("lookup", osm_ids=",".join(ZONES.values()), polygon_geojson=1)
    }
    zones = {zone: contours[int(ref[1:])] for zone, ref in ZONES.items()}

    avenue = _get("lookup", osm_ids=f"W{RUE_MINISTRE}", polygon_geojson=1)[0]["geojson"]["coordinates"]
    i = _plus_proche(avenue, PHARMACIE_RUE_MINISTRE)
    troncon = avenue[max(0, i - 2): i + 3]
    sg1 = tuple(troncon[len(troncon) // 2])
    sos3 = tuple(avenue[min(len(avenue) - 1, i + 4)])

    zone5 = _point_interieur(zones["palmeraie"], (0.004, 0.002))
    palmeraie = _point_interieur(zones["palmeraie"], (-0.003, 0.004))

    entites = [_entite(g, type="zone", id=zone, osm=ZONES[zone]) for zone, g in zones.items()]
    entites += [
        _entite({"type": "LineString", "coordinates": troncon}, type="troncon", id="sg-1", osm=f"W{RUE_MINISTRE}"),
        _entite({"type": "Point", "coordinates": sg1}, type="signalement", id="sg-1"),
        _entite({"type": "Point", "coordinates": ARRET_AVENUE_21}, type="signalement", id="sg-2"),
        # « Zone 5 » n'existe pas dans OSM (donnée fictive) : point placé dans la Riviera Palmeraie.
        _entite({"type": "Point", "coordinates": zone5}, type="signalement", id="sg-3", approximatif=True),
        _entite({"type": "Point", "coordinates": (ARRET_AVENUE_21[0] + 0.0006, ARRET_AVENUE_21[1] + 0.0004)},
                type="sos", id="sos-1", approximatif=True),
        _entite({"type": "Point", "coordinates": (zone5[0] - 0.0008, zone5[1] + 0.0005)},
                type="sos", id="sos-2", approximatif=True),
        _entite({"type": "Point", "coordinates": sos3}, type="sos", id="sos-3"),
        _entite({"type": "Point", "coordinates": palmeraie}, type="sos", id="sos-4", approximatif=True),
    ]
    return {
        "type": "FeatureCollection",
        "attribution": "© contributeurs OpenStreetMap — ODbL (https://www.openstreetmap.org/copyright)",
        "features": entites,
    }


if __name__ == "__main__":
    collection = importer()
    SORTIE.parent.mkdir(parents=True, exist_ok=True)
    SORTIE.write_text(json.dumps(collection, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    for e in collection["features"]:
        print(e["properties"]["type"], e["properties"]["id"], e["geometry"]["type"])

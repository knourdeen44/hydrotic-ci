"""Routes de l'étape 3 : informations publiques, compte, signalements, SOS, agents, administration."""
import psycopg
import pytest

from conftest import URL, jeton
from hydrotic_api import utilisateurs

TREICHVILLE = {"lat": 5.30286, "lon": -4.00653}  # arrêt « Avenue 21 »


def auth(sub: str) -> dict:
    return {"Authorization": f"Bearer {jeton(sub)}"}


def role(sub: str, valeur: str, service: str | None = None) -> None:
    """Crée le compte si besoin et fixe son rôle directement en base."""
    with psycopg.connect(URL) as c:
        c.execute(
            """INSERT INTO utilisateur (id, role, service, prenom) VALUES (%s, %s, %s, 'Agent')
               ON CONFLICT (id) DO UPDATE SET role = EXCLUDED.role, service = EXCLUDED.service""",
            (sub, valeur, service),
        )


# Informations publiques ---------------------------------------------------------------------

def test_niveaux_et_consignes(client):
    niveaux = client.get("/api/niveaux").json()
    assert niveaux["orange"]["label"] == "Risque élevé"
    assert len(client.get("/api/consignes/orange").json()) == 3
    assert client.get("/api/consignes/vert").json() == []
    assert client.get("/api/consignes/violet").status_code == 404


def test_risque_d_une_zone(client):
    r = client.get("/api/zones/treichville/risque").json()
    assert (r["aujourdhui"], r["demain"]) == ("jaune", "orange")
    assert client.get("/api/zones/inconnue/risque").status_code == 404


def test_alertes_diffusees_seulement(client):
    alertes = client.get("/api/alertes").json()
    assert {a["statut"] for a in alertes} == {"ENVOYEE"}
    assert "al-2" not in {a["id"] for a in alertes}


# Compte -------------------------------------------------------------------------------------

def test_profil_modifiable(client):
    r = client.patch("/api/moi", headers=auth("user_profil"),
                     json={"prenom": "Awa", "zonesSuivies": ["palmeraie", "treichville"], "canauxPreferes": ["push"]})
    assert r.status_code == 200
    assert r.json()["nom"] == "Awa"
    assert sorted(r.json()["zonesSuivies"]) == ["palmeraie", "treichville"]
    assert r.json()["canauxPreferes"] == ["push"]
    assert client.patch("/api/moi", headers=auth("user_profil"), json={"zonesSuivies": []}).status_code == 422
    assert client.patch("/api/moi", headers=auth("user_profil"), json={"zonesSuivies": ["lune"]}).status_code == 422


# Signalements -------------------------------------------------------------------------------

def test_liste_avec_distance(client):
    liste = client.get("/api/signalements", params=TREICHVILLE, headers=auth("user_liste")).json()
    sg2 = next(s for s in liste if s["id"] == "sg-2")
    assert sg2["distanceM"] == 0
    assert sg2["position"] == {"lon": TREICHVILLE["lon"], "lat": TREICHVILLE["lat"]}
    assert client.get("/api/signalements").status_code == 401


def test_nouveau_signalement(client):
    r = client.post("/api/signalements", headers=auth("user_auteur"), json={**TREICHVILLE, "hauteurEau": "Genou"})
    assert r.status_code == 201
    s = r.json()
    assert (s["zoneId"], s["statut"], s["oui"], s["estAuteur"], s["maReponse"]) == ("treichville", "A_CONFIRMER", 1, True, "oui")
    # Hors des quartiers suivis.
    assert client.post("/api/signalements", headers=auth("user_auteur"),
                       json={"lat": 0, "lon": 0, "hauteurEau": "Genou"}).status_code == 422
    # L'auteur ne confirme pas son propre signalement.
    assert client.post(f"/api/signalements/{s['id']}/confirmations", headers=auth("user_auteur"),
                       json={"reponse": "oui"}).status_code == 409


def test_confirmation_rue_ministre(client):
    r = client.post("/api/signalements/sg-1/confirmations", headers=auth("user_voisin"), json={"reponse": "oui"})
    assert r.status_code == 200
    s = r.json()["signalement"]
    assert (s["oui"], s["non"], s["statut"], s["maReponse"]) == (8, 1, "CONFIRME", "oui")
    assert r.json()["scoreFiabilite"] == pytest.approx(1.1)
    # Réponse modifiée : compteurs corrigés, pas de second bonus, statut confirmé conservé.
    r = client.post("/api/signalements/sg-1/confirmations", headers=auth("user_voisin"), json={"reponse": "non"})
    s = r.json()["signalement"]
    assert (s["oui"], s["non"], s["statut"]) == (7, 2, "CONFIRME")
    assert r.json()["scoreFiabilite"] == pytest.approx(1.1)
    # « Je ne sais pas » : aucun compteur.
    r = client.post("/api/signalements/sg-1/confirmations", headers=auth("user_doute"), json={"reponse": "inconnu"})
    assert (r.json()["signalement"]["oui"], r.json()["signalement"]["non"]) == (7, 2)
    assert client.post("/api/signalements/sg-x/confirmations", headers=auth("user_doute"),
                       json={"reponse": "oui"}).status_code == 404


# SOS ----------------------------------------------------------------------------------------

def test_sos_envoi_suivi_prise_en_charge(client):
    r = client.post("/api/sos", headers=auth("user_victime"),
                    json={**TREICHVILLE, "precisionM": 12, "nbPersonnes": 3, "hauteurEau": "Genou", "enfantsOuAges": True})
    assert r.status_code == 201
    sos = r.json()
    assert sos["lieu"] == "Treichville"
    assert [e["fait"] for e in sos["etapes"]] == [True, False, False]
    assert "± 12 m transmise" in sos["etapes"][0]["detail"]

    assert client.get(f"/api/sos/{sos['id']}", headers=auth("user_victime")).status_code == 200
    assert client.get(f"/api/sos/{sos['id']}", headers=auth("user_curieux")).status_code == 403
    assert client.get("/api/agent/sos", headers=auth("user_victime")).status_code == 403

    role("user_agent", "AGENT", "ONPC Abidjan Sud")
    assert sos["id"] in {s["id"] for s in client.get("/api/agent/sos", headers=auth("user_agent")).json()}
    assert client.patch(f"/api/agent/sos/{sos['id']}", headers=auth("user_agent"),
                        json={"statut": "SECOURU"}).status_code == 409
    r = client.patch(f"/api/agent/sos/{sos['id']}", headers=auth("user_agent"), json={"statut": "EN_ROUTE"})
    assert r.status_code == 200
    assert r.json()["etapes"][1]["fait"] is True
    assert "ONPC Abidjan Sud" in r.json()["etapes"][1]["detail"]
    # L'auteur voit l'avancement.
    assert client.get(f"/api/sos/{sos['id']}", headers=auth("user_victime")).json()["statut"] == "EN_ROUTE"


def test_sos_sans_position(client):
    r = client.post("/api/sos", headers=auth("user_sans_gps"), json={"nbPersonnes": 1})
    assert r.status_code == 201
    assert (r.json()["lieu"], r.json()["position"]) == ("Position inconnue", None)


# Agents -------------------------------------------------------------------------------------

def test_alertes_agent(client):
    assert client.get("/api/agent/alertes", headers=auth("user_citoyen")).status_code == 403
    role("user_agent2", "AGENT", "Mairie de Treichville")
    toutes = client.get("/api/agent/alertes", headers=auth("user_agent2")).json()
    assert "al-2" in {a["id"] for a in toutes}

    r = client.post("/api/agent/alertes", headers=auth("user_agent2"), json={"zoneId": "treichville", "niveau": "jaune"})
    assert r.status_code == 201
    nouvelle = r.json()
    assert (nouvelle["titre"], nouvelle["statut"]) == ("Vigilance jaune — Treichville", "EN_ATTENTE")
    r = client.post(f"/api/agent/alertes/{nouvelle['id']}/annuler", headers=auth("user_agent2"))
    assert r.json()["statut"] == "ANNULEE"

    r = client.post("/api/agent/alertes/al-2/valider", headers=auth("user_agent2"))
    assert r.json()["statut"] == "ENVOYEE"
    assert client.post("/api/agent/alertes/al-2/valider", headers=auth("user_agent2")).status_code == 409
    assert "al-2" in {a["id"] for a in client.get("/api/alertes").json()}
    assert client.get("/api/agent/modeles", headers=auth("user_agent2")).json()["rouge"].startswith("ALERTE")


def test_niveau_saisi_et_tableau(client):
    role("user_agent3", "AGENT")
    demain = client.get("/api/zones/palmeraie/risque").json()
    r = client.put("/api/agent/previsions", headers=auth("user_agent3"),
                   json={"zoneId": "palmeraie", "jour": "2099-01-01", "niveau": "vert"})
    assert r.status_code == 200
    assert client.get("/api/zones/palmeraie/risque").json()["demain"] == demain["demain"]

    t = client.get("/api/agent/tableau", headers=auth("user_agent3")).json()
    assert t["zonesEnAlerte"]["total"] == 2
    assert t["zonesEnAlerte"]["parNiveau"]["rouge"] >= 1
    assert t["sos"]["actifs"] >= 3
    assert t["alertesDelivrees"] is None
    assert set(t["badges"]) == {"alertes", "sos"}


# Administration -----------------------------------------------------------------------------

def test_administrateur_et_roles(client, monkeypatch):
    monkeypatch.setenv("ADMIN_EMAILS", "chef@onpc.example")
    monkeypatch.setattr(utilisateurs, "profil_clerk",
                        lambda uid: {"prenom": "Chef", "nom": None, "email": "chef@onpc.example" if uid == "user_chef" else None})
    assert client.get("/api/moi", headers=auth("user_chef")).json()["role"] == "ADMIN"
    assert client.get("/api/moi", headers=auth("user_futur_agent")).json()["role"] == "CITOYEN"

    assert client.get("/api/admin/utilisateurs", headers=auth("user_futur_agent")).status_code == 403
    r = client.patch("/api/admin/utilisateurs/user_futur_agent", headers=auth("user_chef"),
                     json={"role": "AGENT", "service": "ONPC Abidjan Nord"})
    assert (r.json()["role"], r.json()["service"]) == ("AGENT", "ONPC Abidjan Nord")
    assert client.get("/api/agent/alertes", headers=auth("user_futur_agent")).status_code == 200
    assert client.patch("/api/admin/utilisateurs/user_chef", headers=auth("user_chef"),
                        json={"role": "CITOYEN"}).status_code == 409
    assert client.patch("/api/admin/utilisateurs/personne", headers=auth("user_chef"),
                        json={"role": "AGENT"}).status_code == 404

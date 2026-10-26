"""Applique les migrations SQL (dossier migrations/), dans l'ordre, une seule fois chacune.

Usage : uv run python -m hydrotic_api.migrate   (DATABASE_URL dans l'environnement)
"""
from pathlib import Path

import psycopg

from .db import connexion

DOSSIER = Path(__file__).parent / "migrations"


def migrer(conn: psycopg.Connection) -> list[str]:
    conn.execute(
        "CREATE TABLE IF NOT EXISTS schema_migration ("
        " nom text PRIMARY KEY, appliquee_le timestamptz NOT NULL DEFAULT now())"
    )
    faites = {ligne["nom"] for ligne in conn.execute("SELECT nom FROM schema_migration")}
    appliquees = []
    for fichier in sorted(DOSSIER.glob("*.sql")):
        if fichier.name in faites:
            continue
        conn.execute(fichier.read_text(encoding="utf-8"))
        conn.execute("INSERT INTO schema_migration (nom) VALUES (%s)", (fichier.name,))
        appliquees.append(fichier.name)
    conn.commit()
    return appliquees


if __name__ == "__main__":
    with connexion() as c:
        noms = migrer(c)
    print(f"Migrations appliquées : {', '.join(noms) if noms else 'aucune (base à jour)'}")

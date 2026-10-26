"""Accès à PostgreSQL (Neon en production, conteneur PostGIS en test)."""
import os
from collections.abc import Iterator
from contextlib import contextmanager

import psycopg
from psycopg.rows import dict_row


def url_base() -> str:
    url = os.environ.get("DATABASE_URL")
    if not url:
        raise RuntimeError("DATABASE_URL n'est pas définie")
    return url


@contextmanager
def connexion() -> Iterator[psycopg.Connection]:
    """Connexion courte (fonctions serverless) ; validée en fin de bloc, annulée en cas d'erreur."""
    with psycopg.connect(url_base(), row_factory=dict_row, autocommit=False) as conn:
        yield conn


def get_db() -> Iterator[psycopg.Connection]:
    """Dépendance FastAPI."""
    with connexion() as conn:
        yield conn

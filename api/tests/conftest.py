"""Tests sur une base PostGIS jetable (TEST_DATABASE_URL), jamais sur Neon."""
import os
from datetime import datetime, timedelta, timezone

import jwt
import psycopg
import pytest
from cryptography.hazmat.primitives.asymmetric import rsa
from fastapi.testclient import TestClient

URL = os.environ.get("TEST_DATABASE_URL")
if not URL:
    pytest.skip("TEST_DATABASE_URL absente (base PostGIS de test)", allow_module_level=True)

os.environ["DATABASE_URL"] = URL
os.environ.setdefault("CLERK_PUBLISHABLE_KEY", "pk_test_ZXhlbXBsZS5jbGVyay5hY2NvdW50cy5kZXYk")  # exemple.clerk.accounts.dev
os.environ["ALLOWED_ORIGINS"] = "https://knourdeen44.github.io,http://localhost:5173"

from hydrotic_api import auth  # noqa: E402
from hydrotic_api.app import app  # noqa: E402
from hydrotic_api.migrate import migrer  # noqa: E402
from hydrotic_api.seed import peupler  # noqa: E402

CLE_PRIVEE = rsa.generate_private_key(public_exponent=65537, key_size=2048)


@pytest.fixture(scope="session", autouse=True)
def base():
    """Schéma vierge, migrations, données de départ."""
    with psycopg.connect(URL, autocommit=True) as c:
        c.execute("DROP SCHEMA public CASCADE; CREATE SCHEMA public;")
    with psycopg.connect(URL, row_factory=psycopg.rows.dict_row) as c:
        migrer(c)
        peupler(c)
    yield


@pytest.fixture(autouse=True)
def cle_de_test(monkeypatch):
    """Les jetons de test sont signés par une clé locale, à la place du JWKS Clerk."""
    monkeypatch.setattr(auth, "cle_publique", lambda _jeton: CLE_PRIVEE.public_key())


def jeton(sub: str = "user_test", azp: str = "https://knourdeen44.github.io", expire_dans: int = 60) -> str:
    maintenant = datetime.now(timezone.utc)
    return jwt.encode(
        {"sub": sub, "azp": azp, "iat": maintenant, "exp": maintenant + timedelta(seconds=expire_dans)},
        CLE_PRIVEE,
        algorithm="RS256",
    )


@pytest.fixture
def client() -> TestClient:
    return TestClient(app)

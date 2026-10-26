"""Authentification : vérification des jetons de session Clerk (JWT signés RS256).

La clé publique est lue dans le JWKS de l'instance Clerk, dont l'adresse se déduit de la clé
publiable (pk_test_… / pk_live_… = base64 de « <frontend-api>$ »).
"""
import base64
import os
from functools import lru_cache

import jwt
from fastapi import Header, HTTPException, status

TOLERANCE_HORLOGE_S = 10


def frontend_api() -> str:
    cle = os.environ.get("CLERK_PUBLISHABLE_KEY") or os.environ.get("NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY")
    if not cle:
        raise RuntimeError("Clé publiable Clerk absente (CLERK_PUBLISHABLE_KEY)")
    encode = cle.split("_", 2)[2]
    return base64.b64decode(encode + "=" * (-len(encode) % 4)).decode().rstrip("$")


@lru_cache(maxsize=1)
def _client_jwks() -> jwt.PyJWKClient:
    return jwt.PyJWKClient(f"https://{frontend_api()}/.well-known/jwks.json", cache_keys=True)


def cle_publique(jeton: str):
    """Clé de signature du jeton (remplacée dans les tests)."""
    return _client_jwks().get_signing_key_from_jwt(jeton).key


# Application citoyenne et tableau de bord publiés, et serveurs de développement.
ORIGINES_PAR_DEFAUT = "https://knourdeen44.github.io,http://localhost:5173,http://localhost:4173"


def origines_autorisees() -> list[str]:
    """Origines acceptées (CORS et revendication « azp » du jeton : application qui l'a obtenu)."""
    valeur = os.environ.get("ALLOWED_ORIGINS", ORIGINES_PAR_DEFAUT)
    return [o.strip() for o in valeur.split(",") if o.strip()]


def verifier_jeton(jeton: str) -> dict:
    revendications = jwt.decode(
        jeton,
        cle_publique(jeton),
        algorithms=["RS256"],
        options={"require": ["exp", "iat", "sub"]},
        leeway=TOLERANCE_HORLOGE_S,
    )
    autorisees = origines_autorisees()
    azp = revendications.get("azp")
    if autorisees and azp and azp not in autorisees:
        raise jwt.InvalidTokenError(f"origine non autorisée : {azp}")
    return revendications


def utilisateur_connecte(authorization: str | None = Header(default=None)) -> dict:
    """Dépendance FastAPI : revendications du jeton « Authorization: Bearer … », sinon 401."""
    if not authorization or not authorization.lower().startswith("bearer "):
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Connexion requise", {"WWW-Authenticate": "Bearer"})
    try:
        return verifier_jeton(authorization.split(" ", 1)[1].strip())
    except (jwt.PyJWTError, RuntimeError) as erreur:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Jeton invalide", {"WWW-Authenticate": "Bearer"}) from erreur

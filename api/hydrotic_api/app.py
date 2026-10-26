"""Application FastAPI."""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .auth import origines_autorisees
from .routes import admin, agent, alertes, compte, public, signalements, sos

app = FastAPI(
    title="API Hydrotic CI",
    version="0.3.0",
    description="Prévention des inondations à Abidjan : zones, prévisions, alertes, signalements, SOS.",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=origines_autorisees(),
    allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE"],
    allow_headers=["Authorization", "Content-Type"],
)

for module in (public, compte, alertes, signalements, sos, agent, admin):
    app.include_router(module.routeur)


@app.get("/")
def accueil() -> dict:
    return {"api": "Hydrotic CI", "version": app.version, "documentation": "/docs"}

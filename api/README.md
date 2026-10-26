# API Hydrotic CI (phase 2)

FastAPI + PostgreSQL/PostGIS (Neon), connexion Clerk. Déployée sur Vercel :
<https://hydrotic-ci-api.vercel.app> (documentation interactive : `/docs`).

## Points d'accès

| Méthode | Chemin | Connexion | Rôle |
|---|---|---|---|
| GET | `/api/sante` | non | État de l'API et de la base |
| GET | `/api/zones` | non | Quartiers : contour réel (GeoJSON, OpenStreetMap) et centre |
| GET | `/api/zones/{id}/pluie` | non | Pluie réelle J-4 à J+2 (Open-Meteo, cache d'une heure) |
| GET | `/api/moi` | oui | Profil ; crée le compte citoyen à la première connexion |

## Sources des données réelles

- **Contours et positions** : OpenStreetMap, importés une fois par `outils/importer_osm.py`
  (Nominatim) dans `hydrotic_api/donnees/osm.geojson` — © contributeurs OpenStreetMap, ODbL.
  Treichville : commune (relation 3308305, lagune et port compris). Riviera Palmeraie : zone
  résidentielle (relation 4600705). « Rue Ministre » : avenue Albert Kakou Tiapani (nom d'usage,
  d'après les commerces cartographiés). « Zone 5 » n'existe pas dans OSM : point placé dans le quartier.
- **Pluie** : Open-Meteo (gratuit sans clé pour un usage non commercial), au centre de chaque
  quartier ; données sous licence CC BY 4.0 (mention à afficher avec les barres de pluie).

Connexion : en-tête `Authorization: Bearer <jeton de session Clerk>`. Le jeton est vérifié avec
les clés publiques de l'instance Clerk ; son origine (`azp`) doit faire partie de
`ALLOWED_ORIGINS` (par défaut : site GitHub Pages et serveurs de développement).

## Configuration (variables Vercel, créées par les intégrations Neon et Clerk)

- `DATABASE_URL` (pooler Neon), `DATABASE_URL_UNPOOLED` (connexion directe, pour les migrations)
- `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY` ou `CLERK_PUBLISHABLE_KEY`, `CLERK_SECRET_KEY`
- `ALLOWED_ORIGINS` (facultatif)

Les valeurs ne sont jamais écrites dans le dépôt : `vercel env pull .env.local` (fichier ignoré).

## Développement

```bash
cd api
uv sync                                                    # Python 3.12 + dépendances
uv run --env-file .env.local uvicorn main:app --reload     # API locale sur la base Neon
TEST_DATABASE_URL=postgresql://… uv run pytest             # tests (base PostGIS jetable)
```

Migrations et données de départ (reprises de `fixtures/`, idempotentes) :

```bash
uv run --env-file .env.local python -m hydrotic_api.migrate   # avec DATABASE_URL = connexion directe
uv run --env-file .env.local python -m hydrotic_api.seed
```

Déploiement : `vercel deploy --prod` depuis `api/`.

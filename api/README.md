# API Hydrotic CI (phase 2)

FastAPI + PostgreSQL/PostGIS (Neon), connexion Clerk. Déployée sur Vercel :
<https://hydrotic-ci-api.vercel.app> (documentation interactive : `/docs`).

## Points d'accès (étape 1)

| Méthode | Chemin | Connexion | Rôle |
|---|---|---|---|
| GET | `/api/sante` | non | État de l'API et de la base |
| GET | `/api/zones` | non | Quartiers suivis (contour GeoJSON quand il est connu) |
| GET | `/api/moi` | oui | Profil ; crée le compte citoyen à la première connexion |

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

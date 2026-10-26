# Vérification de la phase 1 — critères d'acceptation (CLAUDE.md §8)

Chaque critère est vérifié automatiquement à chaque envoi sur `main` par le workflow
`.github/workflows/pages.yml` (runner Ubuntu 24.04). Ce document indique **comment** chaque critère
est contrôlé et le **résultat** au moment de la livraison.

| # | Critère | Résultat | Contrôle |
|---|---|---|---|
| 1 | Chaque écran de `SPEC_UI.md` existe et est accessible par la navigation | ✅ 16 / 16 | `tools/verifier.mjs` (routes) ; tests d'écrans Flutter (`test/screens/`) et Playwright (`tests/dashboard.spec.ts`) qui ouvrent chaque écran par la navigation |
| 2 | Comparaison visuelle avec `design/reference/screens/` : écart de position < ~4 px | ✅ voir tableau ci-dessous | `tools/comparer_maquettes.py` (mobile et D1) ; test Playwright `@reference` (D1 au pixel, tolérance 4 %) |
| 3 | Les 4 scénarios des vidéos se rejouent (enchaînement, durées approximatives) | ✅ | Scénarios 1 à 3 : `test/screens/screens_test.dart`, `demo_test.dart` (minutage du prototype) ; scénario 4 : `tests/demo.spec.ts` (horloge simulée) |
| 4 | Aucune couleur en dur (hors fichiers générés) | ✅ 0 occurrence | `tools/verifier.mjs` (hexadécimal, `rgb()`, `Color(0x…)`, `Colors.*` sauf `transparent`) |
| 5 | Aucun appel réseau | ✅ | `tools/verifier.mjs` (code) ; `tools/verifier_web.mjs` (16 écrans du site compilé, aucune requête externe) ; Playwright (requêtes du tableau de bord) |
| 6 | `flutter analyze` sans erreur ; `flutter test` passe (widgets + golden tests M1 à M4) | ✅ | Étapes « Mobile — analyse / tests / golden tests » |
| 7 | `npm run lint`, `npm run build`, Playwright ; capture de D1 à 1440 × 880 comparée à la référence | ✅ | Étapes « Tableau de bord — … » |
| 8 | Textes en français, identiques à la spécification | ✅ 122 / 122 citations | `tools/verifier.mjs` : 109 citations présentes telles quelles dans les textes ou les données, 13 composées à l'exécution et comparées mot pour mot par `test/spec_textes_test.dart` |

Règles complémentaires de CLAUDE.md, contrôlées aussi : fichiers de 300 lignes au plus (§10),
thème généré depuis `design/tokens.json` et à jour (§5, `gen_tokens --check`).

## Écarts de position avec les maquettes

Mesure de `tools/comparer_maquettes.py` : bandes de texte et d'éléments repérées de haut en bas
dans la maquette et dans la capture (taille logique 340 × 720 pour le mobile, 1440 × 880 pour D1),
puis décalage vertical de chaque bande appariée. Tolérance : 4 px.

| Écran | Bandes appariées | Écart max (px) | Écart moyen (px) | État | Remarque |
|---|---|---|---|---|---|
| M1 Accueil | 7 / 7 | 2 | 0.7 | ✅ |  |
| M1 Accueil (planche) | 7 / 8 | 7 | 4.7 | ℹ️ | indicatif : carte de risque de hauteur automatique (≈ 140 px) sur la planche, 148 px dans les vidéos et tokens.json |
| M2 Alerte (fin) | 12 / 12 | 2 | 0.9 | ✅ |  |
| M4 SOS (repos) | 8 / 8 | 4 | 0.8 | ✅ |  |
| M4 SOS (envoyé) | 8 / 8 | 3 | 1.5 | ✅ |  |
| M3 Carte (légende) | 3 / 3 | 3 | 3.0 | ✅ | feuille au-dessus de la barre du bas (choix validé) : seule la partie haute est comparée |
| D1 Vue d’ensemble | 9 / 10 | 2 | 0.6 | ✅ |  |

## Écarts assumés (décisions prises pendant la phase 1)

- **M3 Carte** : la barre du bas reste visible (onglet « Carte ») et la feuille de confirmation
  se pose au-dessus ; elle recouvre le bouton SOS tant qu'elle est ouverte. Sur la capture v2, la
  carte occupe tout l'écran. Seule la partie haute est donc comparée.
- **M3 Carte, couleur de Treichville** : niveau du jour (jaune) d'après `risk.json` ; le scénario 2
  du mode démo reprend l'orange de la vidéo.
- **M1 et la planche `01_mobile_4_ecrans.png`** : la carte de risque y a une hauteur automatique
  (≈ 140 px) alors que les vidéos et `tokens.json` imposent 148 px. M1 est comparé à la vidéo v1
  (critère bloquant) ; la planche est signalée à titre indicatif.
- **Texte en 12 px** : le moteur de texte de Flutter rend l'Inter ≈ 4 % plus large que le
  navigateur (mêmes fichiers de police, mesuré). La phrase « Restez en hauteur… » (M4, SOS envoyé)
  dispose de 8 px de plus de chaque côté pour rester sur une ligne, comme dans la maquette.
- **Zones tactiles** : 44 px minimum (bouton « Pas d'internet : envoyer le SOS par SMS », puce
  « 2 zones »…), quitte à dépasser légèrement la hauteur de la maquette.
- **Mention « Mode démonstration — données fictives »** : en pied de la barre latérale du tableau
  de bord (absente de la capture D1, ne décale rien).

## Corrections apportées par cette vérification

- Le site compilé chargeait CanvasKit depuis `www.gstatic.com` et la police Roboto depuis
  `fonts.gstatic.com` : CanvasKit est désormais servi avec l'application (`--no-web-resources-cdn`)
  et la police par défaut du moteur web (« Roboto ») est déclarée localement avec les fichiers Inter.
- Test du scénario 2 ajouté (minutage pop / feuille / « Oui » / merci).
- Test des 13 textes composés comparés aux citations de la spécification.
- Hauteur de ligne : le navigateur arrondit au pixel l'ascendante et la descendante de la police
  pour chaque taille (12 px → 15 px de ligne). `tokens.json` décrit désormais les métriques d'Inter
  et `gen_tokens` calcule la hauteur de chaque style mobile de la même façon (écart moyen sur M1 :
  2,0 → 0,7 px ; M4 « SOS envoyé » : 13 → 3 px).
- Frise de suivi du SOS : titre d'étape dans une ligne de 16 px, comme le prototype.

## Relancer la vérification

```bash
node tools/verifier.mjs                      # critères statiques
python3 tools/comparer_maquettes.py sortie/  # écarts avec les maquettes (Pillow)
cd mobile && flutter analyze && flutter test
cd dashboard && npm run lint && npm run build && npx playwright test
```

Les captures de référence (golden tests Flutter, captures Playwright) sont générées en CI :
workflow « Vérification et publication » lancé à la main avec l'option « goldens ».

# CLAUDE.md — Hydrotic CI · Phase 1 : interface seule

> Ce fichier donne à Claude Code le contexte, les règles et l'ordre de travail.
> **Lis-le en entier avant toute action**, puis lis `docs/SPEC_UI.md` (détail de chaque écran) et `design/tokens.json`.

---

## 1. Le projet en bref

**Hydrotic CI** est une application de prévention des inondations urbaines à Abidjan (Côte d'Ivoire). Elle :

1. **prévoit** le risque d'inondation par quartier (vert, jaune, orange, rouge) ;
2. **alerte** les habitants par notification et e-mail ;
3. fait **confirmer** l'état des rues par les habitants sur place (fonctionnement inspiré de Waze) ;
4. permet à une victime d'envoyer sa **position (SOS)** aux autorités.

Deux interfaces :
- **Application citoyenne** (mobile) — habitants de Treichville et de la Riviera Palmeraie (Cocody).
- **Tableau de bord web** — agents de l'ONPC et des mairies.

Le cahier des charges complet est dans `docs/Cahier_des_charges_Hydrotic_CI_v3.pdf` (64 fonctionnalités, 9 modules A à I).

---

## 2. Objectif de cette phase : l'interface, sans fonctionnalité

**À faire :**
- Reproduire **fidèlement** les écrans de référence (`design/reference/`) : mêmes couleurs, tailles, textes, espacements, hiérarchie.
- Rendre la **navigation** fonctionnelle (onglets, ouverture des feuilles, passage d'un écran à l'autre).
- Afficher des **données fictives** chargées depuis `fixtures/*.json` (aucune donnée en dur dans les composants).
- Simuler visuellement les **états** de chaque écran (niveau de risque, question → merci, SOS : repos → maintien → envoyé) avec des interactions locales.

**À NE PAS faire dans cette phase :**
- Aucun appel réseau, aucune API, aucune base de données, aucune authentification réelle.
- Aucune notification push réelle, aucune géolocalisation réelle, aucun envoi de SMS.
- Aucun modèle d'IA, aucun calcul de risque.
- Aucune carte réelle (Leaflet / Google Maps) : la carte est **schématique en SVG**, comme dans les maquettes. La carte réelle viendra en phase 2.
- Ne pas inventer d'écrans, de textes ou de données non décrits ici ou dans `docs/SPEC_UI.md`. En cas de doute, **demander**.

Toute action non encore branchée (ex. « Envoyer le SOS par SMS ») affiche un **toast** : « Disponible dans une prochaine version ».

---

## 3. Pile technique (imposée par le cahier des charges)

| Partie | Technologie | Remarques |
|---|---|---|
| Application citoyenne | **Flutter 3 (stable) + Dart**, Material 3 | Android en priorité, iOS compatible. Gestion d'état : `flutter_riverpod`. Navigation : `go_router`. |
| Tableau de bord | **React 18 + TypeScript + Vite** | Navigation : `react-router-dom`. Styles : **CSS Modules + variables CSS** générées depuis `design/tokens.json` (pas de Tailwind, pour garder les valeurs exactes). Icônes : `lucide-react`. |
| Police | **Inter** (400, 600, 700, 800) | Embarquée dans le projet (pas de chargement réseau à l'exécution). Flutter : fichiers TTF dans `assets/fonts/`. Web : `@fontsource/inter`. |
| Icônes mobile | Icônes Material « rounded » | Elles remplacent les carrés gris des maquettes (`.act i`, `.nav b`), à la même taille. |
| Données | `fixtures/*.json` | Copiées dans `mobile/assets/fixtures/` et `dashboard/src/fixtures/`. |

Ne pas ajouter d'autre dépendance sans le justifier dans le message de commit.

---

## 4. Structure du dépôt attendue

```
hydrotic-ci/
├── CLAUDE.md                  ← ce fichier
├── docs/                      ← cahier des charges, SPEC_UI.md, diagrammes UML
├── design/
│   ├── tokens.json            ← SOURCE UNIQUE des couleurs, typos, rayons, tailles
│   └── reference/             ← captures, prototype HTML/CSS, vidéos de démo
├── fixtures/                  ← données fictives (JSON)
├── assets/                    ← logos Hydrotic
├── mobile/                    ← application Flutter
│   ├── lib/
│   │   ├── main.dart
│   │   ├── theme/             ← hydrotic_colors.dart, hydrotic_text.dart, hydrotic_theme.dart (générés depuis tokens.json)
│   │   ├── data/              ← modèles Dart + lecture des fixtures (repositories « mock »)
│   │   ├── widgets/           ← composants réutilisables (voir §6)
│   │   └── screens/           ← un dossier par écran (voir SPEC_UI)
│   ├── assets/{fonts,fixtures,images}/
│   └── test/                  ← tests de widgets + golden tests
└── dashboard/                 ← tableau de bord React
    ├── src/
    │   ├── styles/tokens.css  ← variables CSS générées depuis tokens.json
    │   ├── components/
    │   ├── pages/
    │   └── fixtures/
    └── tests/                 ← Playwright (captures comparées aux références)
```

---

## 5. Règles de design (non négociables)

1. **Toutes les couleurs viennent de `design/tokens.json`.** Aucun code hexadécimal en dur dans un widget ou un composant.
2. **Couleurs de risque** (vert `#3F8F5B`, jaune `#D9A520`, orange `#D9731E`, rouge `#C0392B`) : réservées aux niveaux de risque, aux statuts d'urgence et au SOS. **Toujours accompagnées d'un mot** (« Vigilance », « Risque élevé »…), jamais la couleur seule.
3. **Couleurs de marque dominantes** : Slate Blue `#6C809A` et Dark Gray `#464A4F`. Deep Blue `#1B3A60` en accent ponctuel uniquement.
4. **Police Inter partout.** Tailles et graisses : `tokens.json > typography`.
5. **Rayons** : cartes 18, mini-cartes et boutons 14, feuille du bas 24 (haut seulement), puces 20. Tableau de bord : panneaux 14, boutons 10.
6. **Zones tactiles ≥ 44 px.** Texte mobile ≥ 10 px (libellés de navigation), corps ≥ 13 px.
7. **Le bouton SOS est visible sur tous les écrans de l'application citoyenne** (bouton flottant rouge de 62 px, 18 px du bord droit, 16 px au-dessus de la barre de navigation), sauf sur l'écran SOS lui-même.
8. **Langue : français.** Reprendre les textes **exactement** comme dans `docs/SPEC_UI.md` et les fixtures (accents, espaces insécables avant « : », « ? », « % »).
9. **Mention « données fictives »** visible en mode démo (petit bandeau discret dans le profil et en pied du tableau de bord).
10. Accessibilité : contraste AA, `Semantics`/`aria-label` sur les boutons icônes, le bouton SOS annonce « Bouton SOS, maintenir trois secondes ».

---

## 6. Composants à créer (mobile)

Chaque composant correspond à une classe CSS du prototype `design/reference/prototype/app.css`. **Reprends les valeurs de ce fichier.**

| Composant | Classe de référence | Points clés |
|---|---|---|
| `HydroticHeader` | `.top` | Logo 34 px, « Bonjour {prénom} » 16/700, quartier 12 gris clair, puce « 2 zones » |
| `RiskCard` | `.risk` | Hauteur 148, rayon 18, fond = couleur du niveau, sur-titre MAJUSCULES 12/600 espacé 1 px, titre 26/800, message 13 ; transition en fondu (500 ms) quand le niveau change |
| `MiniStat` | `.mini` | Fond `slateXLight`, rayon 14, libellé 11, valeur 15/700 avec pastille de couleur |
| `RainBars` | `.bars` + `.lbl` | 7 barres, hauteur 70, écart 7, barres de prévision **hachurées** (45°, 4 px) |
| `QuickActions` | `.acts` | 3 cases : Carte, Signaler, Consignes |
| `SosFab` | `.sosfab` | 62 px, rouge, « SOS » 15/800, ombre rouge |
| `BottomNav` | `.nav` | 64 px, 4 onglets : Accueil, Carte, Alertes, Profil ; actif = `slateDark` 700 |
| `NotificationBanner` | `.banner` | Aperçu de notification (simulé) : entre par le haut, reste 2,5 s, ressort |
| `BottomSheet` | `.sheet` + `.grab` | Rayon 24 en haut, poignée 40×4, ombre vers le haut |
| `ConsignesSheet` | `.cons` | Liste numérotée, pastilles de la couleur du niveau |
| `ConfirmQuestionSheet` | `.q .qs .ans .meta` | 3 boutons : Oui (slate plein), Non (slateLight), Je ne sais pas (contour) ; état « Merci » en fondu |
| `SchematicMap` | `.map` + SVG | Carte SVG : zones depuis `zones.json` (`svgMobile`), signalements et position depuis `reports.json`, légende en haut à gauche |
| `SosHoldButton` | `.ringwrap` `.ringbtn` | Bouton 150 px dans un anneau de 190 px ; l'anneau se remplit en **3 s** pendant l'appui, se vide si on relâche avant |
| `SosStatusTimeline` | `.sent` `.tl` `.step` | 3 étapes : Reçu, Équipe en route, Secouru |
| `StatusChip` | `.st.r/.e/.s` (dashboard) | Reçu / En route / Secouru |

Dashboard : `Sidebar`, `KpiCard`, `Panel`, `RiskMap` (SVG `svgDashboard`), `PendingAlertCard`, `SosTable`, `StatusChip` — valeurs dans `design/reference/prototype/s4_dashboard.html` (bloc `<style>`).

---

## 7. Ordre de travail

Avance **étape par étape**, et **arrête-toi à la fin de chaque étape** pour montrer une capture et attendre la validation.

1. **Initialisation** : créer `mobile/` (Flutter) et `dashboard/` (Vite React TS), installer Inter, copier les fixtures et les logos.
2. **Thème** : script `tools/gen_tokens` (Node ou Dart) qui génère `hydrotic_colors.dart`, `hydrotic_text.dart` et `tokens.css` depuis `design/tokens.json`. Ne jamais modifier les fichiers générés à la main.
3. **Couche données fictives** : modèles (Zone, Niveau, Alerte, Signalement, SOS, Utilisateur) et dépôts « mock » qui lisent les JSON. Les noms suivent le diagramme `docs/uml_classes.png`.
4. **Composants mobile** (§6) avec une page « catalogue » de développement qui les affiche tous.
5. **Écrans mobile** dans l'ordre de `docs/SPEC_UI.md` : M1 Accueil → M2 Alerte → M3 Carte + confirmation → M4 SOS → M5 Alertes → M6 Profil → M7 Signaler → M0 Accueil de démarrage.
6. **Tableau de bord** : D1 Vue d'ensemble (fidèle à la capture), puis D2 à D8 en structure (titres, tableaux vides alimentés par les fixtures).
7. **Mode démo** : un menu caché (appui long sur le logo) qui rejoue les 4 scénarios des vidéos de référence.
8. **Vérification** (§8).

---

## 8. Critères d'acceptation de la phase 1

- [ ] Chaque écran listé dans `docs/SPEC_UI.md` existe et est accessible par la navigation.
- [ ] Comparaison visuelle avec les captures de `design/reference/screens/` : mêmes couleurs, textes, ordre des éléments ; écart de position inférieur à ~4 px sur un écran de 360 × 740.
- [ ] Les 4 scénarios des vidéos `design/reference/videos/` se rejouent à l'identique (enchaînement et durées approximatives).
- [ ] Aucune couleur en dur ; `grep` des codes hexadécimaux hors fichiers générés = 0 résultat.
- [ ] Réseau (phase 2) : appels seulement depuis les clients d'API (`dashboard/src/data/api/`, `mobile/lib/data/api/`), vers les hôtes autorisés (API Hydrotic, Clerk, tuiles OpenStreetMap). Mode démo : aucun appel.
- [ ] `flutter analyze` sans erreur ; `flutter test` passe (tests de widgets + golden tests des écrans M1 à M4).
- [ ] `npm run lint`, `npm run build` et les tests Playwright passent ; capture de D1 à 1440 × 880 comparée à `02_dashboard_vue_ensemble.png`.
- [ ] Tous les textes en français, identiques à la spécification.

---

## 9. Commandes utiles

```bash
# Mobile
cd mobile && flutter pub get && flutter run            # lancer
flutter analyze && flutter test                         # vérifier
flutter test --update-goldens                           # régénérer les captures de référence (seulement si validé)

# Tableau de bord
cd dashboard && npm install && npm run dev              # lancer (http://localhost:5173)
npm run lint && npm run build && npx playwright test    # vérifier

# Tokens
node tools/gen_tokens.mjs                               # régénérer thème Flutter + tokens.css
```

---

## 10. Conventions

- Code et noms de fichiers en anglais ; **textes affichés en français** ; commentaires en français.
- Commits courts, au présent : `ui(mobile): écran Accueil avec carte de risque`.
- Un composant = un fichier. Pas de fichier de plus de 300 lignes.
- Les textes affichés sont centralisés (`lib/l10n/fr.dart` côté Flutter, `src/i18n/fr.ts` côté web) pour préparer les langues locales (version 3).

## 11. Phases suivantes (hors périmètre, pour information)

Phase 2 : API FastAPI + PostgreSQL/PostGIS, carte réelle (Leaflet / flutter_map + OpenStreetMap), authentification. Phase 3 : moteur d'alertes (Firebase Cloud Messaging, e-mail), confirmation communautaire réelle, SOS réel. Phase 4 : modèle d'IA de prévision. Le code de la phase 1 doit permettre de remplacer les dépôts « mock » par des dépôts API **sans toucher aux écrans**.

**Phase 2 (faite)** : API FastAPI sur Vercel + Neon (PostGIS), connexion Clerk, contours OpenStreetMap, pluie Open-Meteo, carte Leaflet / flutter_map, GPS, signalements, confirmations et SOS partagés. Mode réel par défaut sur le site publié ; mode démo (fixtures) pour les tests, les captures et les scénarios (bascule : Ctrl + D sur le tableau de bord).

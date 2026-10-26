# SPEC_UI — Écrans de la phase 1 (interface seule)

Référence visuelle : `design/reference/screens/` (captures) et `design/reference/prototype/` (HTML/CSS ouvrables dans un navigateur).
Toutes les données affichées viennent de `fixtures/`. Les textes entre guillemets sont à reprendre **mot pour mot**.

Légende : 🖼️ = maquette de référence disponible · ✏️ = pas de maquette, composer **uniquement** avec les composants et tokens existants.

---

## A. Application citoyenne (Flutter)

Taille de référence : 360 × 740 (zone utile 340 × 720). L'interface doit rester correcte de 320 à 430 de large.

### M0 — Démarrage ✏️
1. **Bienvenue** : logo complet (`assets/logo_hydrotic_full.png`, 160 px) centré, titre « Hydrotic CI » 26/800, sous-titre « Prévoir, alerter et secourir face aux inondations » 13 gris clair ; boutons pleine largeur « Créer un compte » (slate plein) et « J'ai déjà un compte » (slateLight).
2. **Connexion / inscription** : champs « E-mail » et « Mot de passe » (rayon 14, fond `slateXLight`) ; le bouton mène à l'étape 3 sans vérification.
3. **Mes quartiers** : titre « Quels quartiers voulez-vous suivre ? » ; deux cartes cochables issues de `zones.json` (« Treichville » / « Riviera Palmeraie — Cocody ») avec leur profil en sous-texte.
4. **Autorisations** : deux cartes explicatives « Notifications » (« Pour recevoir les alertes de vos quartiers, même application fermée. ») et « Localisation » (« Uniquement pour signaler, confirmer une inondation ou envoyer un SOS. ») avec interrupteurs **simulés** ; bouton « Commencer » → M1.

### M1 — Accueil 🖼️ (`01_mobile_4_ecrans.png`, écran 1 ; `v1_alerte_debut.png`)
De haut en bas :
- Barre d'état (système).
- `HydroticHeader` : « Bonjour Awa », « Treichville · Avenue 21 », puce « 2 zones ».
- `RiskCard` pour **demain** dans la zone principale. Sur-titre « DEMAIN · NIVEAU {NIVEAU} », titre et message depuis `risk.json > niveaux`.
- Rangée de 2 `MiniStat` : « Aujourd'hui » + pastille + libellé du niveau du jour ; « Signalements » + « {n} confirmés ».
- Titre de section « Pluie (mm) — 5 derniers jours et prévision » + `RainBars` (`risk.json > pluie`).
- Titre « Accès rapide » + `QuickActions` : Carte → M3, Signaler → M7, Consignes → feuille `ConsignesSheet`.
- `SosFab` → M4. `BottomNav` (Accueil actif).
- Un sélecteur discret (appui sur la puce « 2 zones ») permet de basculer Treichville / Riviera Palmeraie.

### M2 — Réception d'une alerte 🖼️ (`v1_alerte_fin.png`, vidéo `v1_alerte.mp4`)
Scénario simulé déclenché depuis le mode démo :
1. À t = 1,4 s, `NotificationBanner` descend du haut : en-tête « HYDROTIC CI · maintenant », titre « ALERTE ORANGE — Treichville » (orange), corps de `alerts.json > al-1`.
2. Un appui sur la bannière la fait remonter ; la `RiskCard` passe de jaune à orange en fondu (500 ms).
3. `ConsignesSheet` monte (600 ms) au-dessus de la barre de navigation : titre « Que faire avant demain ? », sous-titre « Consignes pour le niveau orange · Treichville », 3 consignes numérotées (`risk.json > consignes.orange`).

Aperçu écran verrouillé (`01_mobile_4_ecrans.png`, écran 2) : uniquement dans le mode démo, pour la présentation.

### M3 — Carte et confirmation communautaire 🖼️ (écran 3 ; vidéo `v2_confirmation.mp4`)
- `SchematicMap` plein écran (fond `#EEF1F4`, routes blanches, plan d'eau `#DCE4EC`) avec les zones de `zones.json` (contour + remplissage de la couleur du niveau), les signalements (`reports.json`) et la position « Vous » (point Deep Blue avec halo).
- Légende en haut à gauche : « Inondé (confirmé) », « Signalement », « Vous ».
- Le signalement `sg-1` (rue Ministre) apparaît avec une animation « pop » + pulsation.
- `ConfirmQuestionSheet` : « La rue Ministre est-elle toujours inondée ? », « Vous êtes à 140 m. Votre réponse aide vos voisins et les secours. », boutons « Oui » / « Non » / « Je ne sais pas », pied « Signalé il y a 38 min » / « 7 « oui » · 1 « non » ».
- Après « Oui » : fondu vers l'état merci — pastille ✓, « Merci, c'est noté ! », « Rue Ministre : **inondation confirmée** par 8 habitants. Les autorités voient l'information sur leur tableau de bord. », pied « Votre fiabilité : 1,2 » / « 8 « oui » · 1 « non » » ; la zone et le tronçon passent en rouge.
- Après « Non » ou « Je ne sais pas » : même feuille merci, sans changement de couleur (état local).

### M4 — SOS 🖼️ (écran 4 ; vidéo `v3_sos.mp4`)
États :
1. **Repos** : « Besoin d'aide ? », « Maintenez le bouton 3 secondes. Votre position sera transmise aux secours. », `SosHoldButton` (« SOS », « Maintenir 3 s »), carte position « Position GPS trouvée » / « Précision ± 12 m · Treichville, avenue 21 » (valeur fictive), 4 options (Personnes 3, Blessés Non, Hauteur d'eau Genou, Enfants / âgés Oui — modifiables localement), bouton pointillé « Pas d'internet : envoyer le SOS par SMS » (→ toast).
2. **Maintien** : l'anneau rouge se remplit en 3 s ; relâcher avant = annulation, l'anneau se vide.
3. **Envoyé** : fondu vers « SOS envoyé », « Restez en hauteur et gardez votre téléphone allumé. », `SosStatusTimeline` (`sos.json > sosCourant.timeline`) ; en démo, l'étape « Équipe en route » se coche 2,4 s plus tard, puis le bloc « Les secours sont informés » / « Votre position est mise à jour toutes les 2 minutes. » apparaît.
- Pas de `SosFab` sur cet écran ; flèche retour en haut à gauche.

### M5 — Alertes ✏️
- Onglet `BottomNav` « Alertes ».
- En haut : l'alerte en cours (carte colorée comme `RiskCard`, version compacte 96 px) + bouton « Voir les consignes ».
- Liste « Historique » : une ligne par alerte de `alerts.json` (pastille de niveau + titre + date + source « Modèle Hydrotic »).
- Section « Bulletins officiels » : carte vide avec le texte « Les bulletins de la SODEXAM et de l'ONPC apparaîtront ici. » (aucune donnée inventée).

### M6 — Profil ✏️
- Bloc identité : « Awa », « Citoyenne · Treichville ».
- « Mes quartiers » : puces des zones suivies + « Modifier » (→ écran 3 de M0).
- « Canaux d'alerte » : interrupteurs « Notifications » et « E-mail » (état local) ; ligne non désactivable « Les alertes rouges sont toujours affichées dans l'application ».
- « Ma fiabilité » : « 1,2 » + explication « Votre score augmente quand vos réponses rejoignent celles de vos voisins. »
- « Numéros utiles » : texte « À compléter avec les numéros officiels vérifiés. » — **ne pas écrire de numéros**.
- « Données personnelles » : « Supprimer mon compte » (→ toast).
- Bandeau « Mode démonstration — données fictives ».

### M7 — Signaler une inondation ✏️
- Titre « Signaler une inondation ».
- Mini `SchematicMap` (hauteur 200) avec la position « Vous ».
- « Hauteur d'eau » : 3 puces sélectionnables « Cheville », « Genou », « Taille ».
- « Photo (facultatif) » : zone pointillée « Ajouter une photo » (→ toast).
- « Commentaire » : champ texte.
- Bouton « Envoyer le signalement » : ajoute un signalement **local** sur la carte M3 avec le statut « À confirmer », puis toast « Merci ! Vos voisins vont être interrogés. »

---

## B. Tableau de bord des autorités (React)

Taille de référence : 1440 × 880. Doit rester lisible jusqu'à 1280 de large.
Structure commune : `Sidebar` 230 px fond `gray` (logo sur pastille blanche, « Hydrotic CI » / « Espace autorités », menu `dashboard.json > menu` avec badges rouges) + zone principale fond `slateXLight`, marge 22/26.

### D1 — Vue d'ensemble 🖼️ (`02_dashboard_vue_ensemble.png` ; vidéo `v4_dashboard.mp4`)
- En-tête : titre et sous-titre de `dashboard.json > entete` ; bouton « + Alerte manuelle » (→ toast).
- 4 `KpiCard` (`dashboard.json > kpis`).
- Grille 1,55 fr / 1 fr :
  - **Gauche** : panneau « Carte des risques, signalements et victimes » + mention « Schéma illustratif » ; `RiskMap` SVG (zones `svgDashboard`, SOS en points rouges, signalements en carrés slate) ; légende en bas à gauche.
  - **Droite haut** : « Alerte en attente de validation » — `PendingAlertCard` (`alerts.json > al-2`) avec « Valider et envoyer » (rouge), « Modifier », « Annuler ». « Valider » → l'état passe à « ✓ Envoyée · push + e-mail » (état local).
  - **Droite bas** : « SOS victimes » / « temps réel » — `SosTable` (`sos.json > liste`) avec `StatusChip`. Un clic sur un statut le fait avancer (Reçu → En route → Secouru), état local.
- Pied discret : « Mode démonstration — données fictives ».

### D2 — Alertes ✏️
Tableau : Niveau · Zone · Titre · Date · Statut · Source (`alerts.json`). Filtre par zone et par niveau (local).

### D3 — SOS victimes ✏️
Version pleine page de `SosTable` + `RiskMap` réduite filtrée sur les SOS.

### D4 — Signalements ✏️
Tableau : Rue · Zone · « oui » · « non » · Statut · Il y a (`reports.json`).

### D5 — Prévisions ✏️
Par zone : carte du niveau aujourd'hui / demain + `RainBars` en grand. Aucune courbe inventée.

### D6 — Historique & export ✏️
Tableau des alertes + bouton « Exporter en CSV » (→ toast).

### D7 — Zones et seuils ✏️
Liste des zones et sous-zones (`zones.json`) ; tableau des seuils de niveau en lecture seule : Vert < 20 %, Jaune 20–40 %, Orange 40–70 %, Rouge > 70 % (valeurs de départ du cahier des charges, section 11.1).

### D8 — Supervision ✏️
Cartes d'état « Collecte des données », « Modèle de prévision », « Envoi des alertes » avec la mention « Non connecté (phase 1) ».

---

## C. Mode démo

Accès : appui long (1 s) sur le logo (mobile) ou `Ctrl + D` (tableau de bord). Menu :
1. « Scénario 1 — Alerte la veille » (M2)
2. « Scénario 2 — Confirmation rue Ministre » (M3)
3. « Scénario 3 — SOS » (M4)
4. « Scénario 4 — Tableau de bord » (D1 : apparition d'un SOS, validation de l'alerte rouge, passage « En route »)
5. « Réinitialiser les données »

Durées et enchaînements : copier les vidéos de `design/reference/videos/` et les délais d'animation des fichiers `s1` à `s4` du prototype (attributs `animation: … delay`).

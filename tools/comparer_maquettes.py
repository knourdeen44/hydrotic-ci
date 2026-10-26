#!/usr/bin/env python3
"""Compare les captures de l'application aux captures de référence (design/reference/screens/).

Critère (CLAUDE.md §8) : écart de position inférieur à ~4 px sur l'écran mobile (360 × 740) et
sur le tableau de bord (1440 × 880). Méthode : on repère, de haut en bas, les bandes de pixels
foncés (lignes de texte, pastilles) dans la référence et dans la capture, puis on mesure le
décalage vertical de chaque bande appariée.

Usage : python3 tools/comparer_maquettes.py [dossier_de_sortie]
Dépendance : Pillow (pip install pillow). Sortie : tableau Markdown ; images côte à côte si un
dossier est donné. Code de sortie 1 si un écran comparé dépasse la tolérance.
"""
import sys
from pathlib import Path

from PIL import Image

RACINE = Path(__file__).resolve().parent.parent
REF = RACINE / 'design/reference/screens'
GOLDENS = RACINE / 'mobile/test/goldens'
CAPTURES_WEB = RACINE / 'dashboard/tests/captures'
TOLERANCE = 4

# Zone utile d'un téléphone (340 × 720) dans les captures de référence.
V_CROP = (75, 100, 925, 1900)        # vidéos v1–v3 : scène 400 × 800 rendue à 2,5×
PLANCHE_ECRAN1 = (76, 76, 756, 1516)  # 01_mobile_4_ecrans.png, écran 1, rendu à 2×

# (nom, référence, recadrage, capture, taille logique, zone mesurée (x0, y0, x1, y1), remarque).
# Une remarque commençant par « indicatif » : écart signalé sans faire échouer la vérification.
PAIRES = [
    ('M1 Accueil', 'v1_alerte_debut.png', V_CROP, GOLDENS / 'm1_alerte_debut.png', (340, 720), (16, 34, 324, 650), ''),
    ('M1 Accueil (planche)', '01_mobile_4_ecrans.png', PLANCHE_ECRAN1, GOLDENS / 'm1_accueil.png', (340, 720), (16, 34, 324, 600),
     'indicatif : carte de risque de hauteur automatique (≈ 140 px) sur la planche, 148 px dans les vidéos et tokens.json'),
    ('M2 Alerte (fin)', 'v1_alerte_fin.png', V_CROP, GOLDENS / 'm2_alerte_fin.png', (340, 720), (16, 34, 324, 650), ''),
    ('M4 SOS (repos)', 'v3_sos_debut.png', V_CROP, GOLDENS / 'm4_sos_debut.png', (340, 720), (16, 34, 324, 560), ''),
    ('M4 SOS (envoyé)', 'v3_sos_fin.png', V_CROP, GOLDENS / 'm4_sos_fin.png', (340, 720), (16, 60, 324, 500), ''),
    ('M3 Carte (légende)', 'v2_confirmation_debut.png', V_CROP, GOLDENS / 'm3_carte_debut.png', (340, 720), (16, 40, 160, 110),
     'feuille au-dessus de la barre du bas (choix validé) : seule la partie haute est comparée'),
    ('D1 Vue d’ensemble', '02_dashboard_vue_ensemble.png', None, CAPTURES_WEB / 'd1.png', (1440, 880), (250, 0, 1420, 880), ''),
]


def charger(chemin, recadrage, taille):
    image = Image.open(chemin).convert('L')
    if recadrage:
        image = image.crop(recadrage)
    return image.resize(taille, Image.LANCZOS)


def bandes(image, zone, seuil=140):
    """Lignes contenant des pixels foncés, regroupées en bandes (début, fin)."""
    x0, y0, x1, y1 = zone
    pixels = image.load()
    lignes = [y for y in range(y0, y1) if any(pixels[x, y] < seuil for x in range(x0, x1))]
    resultat = []
    for y in lignes:
        if resultat and y == resultat[-1][1] + 1:
            resultat[-1][1] = y
        else:
            resultat.append([y, y])
    return [b for b in resultat if b[1] - b[0] >= 2]  # bruit écarté


def apparier(ref, cap):
    """Décalage de début de chaque bande de référence avec la bande capturée la plus proche."""
    ecarts = []
    for debut, fin in ref:
        candidats = [c for c in cap if abs((c[1] - c[0]) - (fin - debut)) <= 4 and abs(c[0] - debut) <= 16]
        if candidats:
            ecarts.append(min((c[0] - debut for c in candidats), key=abs))
    return ecarts


def main():
    sortie = Path(sys.argv[1]) if len(sys.argv) > 1 else None
    if sortie:
        sortie.mkdir(parents=True, exist_ok=True)
    echec = False
    print('| Écran | Bandes appariées | Écart max (px) | Écart moyen (px) | État | Remarque |')
    print('|---|---|---|---|---|---|')
    for nom, ref_nom, recadrage, capture, taille, zone, remarque in PAIRES:
        if not capture.exists():
            print(f'| {nom} | — | — | — | ⚠️ capture absente | {capture.relative_to(RACINE)} |')
            continue
        ref = charger(REF / ref_nom, recadrage, taille)
        cap = charger(capture, None, taille)
        b_ref, b_cap = bandes(ref, zone), bandes(cap, zone)
        ecarts = apparier(b_ref, b_cap)
        maxi = max((abs(e) for e in ecarts), default=0)
        moyen = sum(abs(e) for e in ecarts) / len(ecarts) if ecarts else 0
        ok = maxi <= TOLERANCE and len(ecarts) >= len(b_ref) * 0.7
        indicatif = remarque.startswith('indicatif')
        echec |= not ok and not indicatif
        etat = '✅' if ok else ('ℹ️' if indicatif else '❌')
        print(f"| {nom} | {len(ecarts)} / {len(b_ref)} | {maxi} | {moyen:.1f} | {etat} | {remarque} |")
        if sortie:
            cote = Image.new('L', (taille[0] * 2 + 20, taille[1]), 255)
            cote.paste(ref, (0, 0))
            cote.paste(cap, (taille[0] + 20, 0))
            cote.save(sortie / f"{nom.split()[0].lower()}_{capture.stem}.png")
    sys.exit(1 if echec else 0)


if __name__ == '__main__':
    main()

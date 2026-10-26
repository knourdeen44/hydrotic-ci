#!/usr/bin/env node
// Vérification automatique des critères d'acceptation de la phase 1 (CLAUDE.md §8) qui se
// contrôlent sans exécuter les applications. Les autres (tests, analyse, captures) tournent en CI.
// Usage : node tools/verifier.mjs   → tableau Markdown ; code de sortie 1 si un critère échoue.
import { execFileSync } from 'node:child_process'
import { readFileSync, readdirSync, statSync } from 'node:fs'
import { join, relative } from 'node:path'
import { fileURLToPath } from 'node:url'

const racine = join(fileURLToPath(new URL('.', import.meta.url)), '..')
const rel = (f) => relative(racine, f)

function fichiers(dossier, extensions) {
  const out = []
  for (const nom of readdirSync(join(racine, dossier))) {
    const chemin = join(racine, dossier, nom)
    if (['node_modules', 'build', 'dist', '.dart_tool'].includes(nom)) continue
    if (statSync(chemin).isDirectory()) out.push(...fichiers(rel(chemin), extensions))
    else if (extensions.some((e) => nom.endsWith(e))) out.push(chemin)
  }
  return out
}

const code = [
  ...fichiers('mobile/lib', ['.dart']),
  ...fichiers('dashboard/src', ['.ts', '.tsx', '.css']),
]
const generes = ['mobile/lib/theme/hydrotic_colors.dart', 'dashboard/src/styles/tokens.css']
const lire = (f) => readFileSync(f, 'utf8')
// Commentaires retirés (on ne contrôle que le code).
const sansCommentaires = (s) => s.replace(/\/\*[\s\S]*?\*\//g, '').replace(/(^|[^:'"])\/\/.*$/gm, '$1')

const resultats = []
const verifier = (critere, problemes, detailOk) =>
  resultats.push({ critere, ok: problemes.length === 0, detail: problemes.length ? problemes.join('<br>') : detailOk })

// 1. Couleurs : aucune valeur en dur hors fichiers générés depuis design/tokens.json.
{
  const motif = /#[0-9a-fA-F]{3,8}\b|rgba?\(|hsla?\(|0x[0-9a-fA-F]{8}|Color\.from(ARGB|RGBO)|\bColors\.(?!transparent\b)\w+/g
  const problemes = []
  for (const f of code.filter((f) => !generes.includes(rel(f)))) {
    sansCommentaires(lire(f)).split('\n').forEach((ligne, i) => {
      for (const m of ligne.matchAll(motif)) problemes.push(`${rel(f)}:${i + 1} « ${m[0]} »`)
    })
  }
  verifier('Aucune couleur en dur (hors fichiers générés)', problemes, `${code.length} fichiers, 0 occurrence`)
}

// 2. Réseau : aucun appel (API, HTTP, WebSocket) dans le code.
{
  const motif = /package:http\b|package:dio\b|\bHttpClient\b|\bfetch\(|XMLHttpRequest|\baxios\b|WebSocket|https?:\/\//g
  const problemes = []
  for (const f of code) {
    sansCommentaires(lire(f)).split('\n').forEach((ligne, i) => {
      for (const m of ligne.matchAll(motif)) problemes.push(`${rel(f)}:${i + 1} « ${m[0]} »`)
    })
  }
  verifier('Aucun appel réseau dans le code', problemes, '0 occurrence (http, dio, fetch, XMLHttpRequest, WebSocket, URL)')
}

// 3. Taille des fichiers : 300 lignes au plus (CLAUDE.md §10).
{
  const tous = [...code, ...fichiers('mobile/test', ['.dart']), ...fichiers('dashboard/tests', ['.ts']), ...fichiers('tools', ['.mjs'])]
  const longs = tous.map((f) => [f, lire(f).split('\n').length - 1]).filter(([, n]) => n > 300)
  verifier('Fichiers de 300 lignes au plus', longs.map(([f, n]) => `${rel(f)} : ${n} lignes`), `${tous.length} fichiers`)
}

// 4. Fichiers générés à jour (thème Flutter et variables CSS).
{
  let problemes = []
  try {
    execFileSync('node', [join(racine, 'tools/gen_tokens.mjs'), '--check'], { stdio: 'pipe' })
  } catch (e) {
    problemes = [String(e.stderr).trim()]
  }
  verifier('Thème généré depuis design/tokens.json, à jour', problemes, 'gen_tokens --check')
}

// 5. Écrans : chaque écran de SPEC_UI a sa route.
{
  const routesMobile = lire(join(racine, 'mobile/lib/router.dart'))
  const routesWeb = lire(join(racine, 'dashboard/src/App.tsx'))
  const ecrans = {
    M0: ["'/demarrage'", routesMobile], M1: ["path: '/'", routesMobile], M2: ["'alerte'", routesMobile],
    M3: ["'/carte'", routesMobile], M4: ["'/sos'", routesMobile], M5: ["'/alertes'", routesMobile],
    M6: ["'/profil'", routesMobile], M7: ["'/signaler'", routesMobile],
    D1: ['<Route index', routesWeb], D2: ['path="alertes"', routesWeb], D3: ['path="sos"', routesWeb],
    D4: ['path="signalements"', routesWeb], D5: ['path="previsions"', routesWeb], D6: ['path="historique"', routesWeb],
    D7: ['path="zones"', routesWeb], D8: ['path="supervision"', routesWeb],
  }
  const manquants = Object.entries(ecrans).filter(([, [motif, src]]) => !src.includes(motif)).map(([e]) => e)
  verifier('Chaque écran de SPEC_UI a une route', manquants.map((e) => `${e} sans route`), `${Object.keys(ecrans).length} écrans (M0–M7, D1–D8)`)
}

// 6. Textes : chaque citation « … » de SPEC_UI figure dans les textes ou données, ou est vérifiée
//    par un test (textes composés à l'exécution : gabarit + données).
{
  const norm = (s) =>
    s.replace(/ |\$\{?nbsp\}?|\$\{NBSP\}|\\u00A0/g, ' ').replace(/\\'/g, "'").replace(/\*\*/g, '').replace(/\s+/g, ' ')
  const sources = norm([...code, ...fichiers('fixtures', ['.json'])].map(lire).join('\n'))
  const tests = norm([...fichiers('mobile/test', ['.dart']), ...fichiers('dashboard/tests', ['.ts'])].map(lire).join('\n'))
  const citations = [...lire(join(racine, 'docs/SPEC_UI.md')).matchAll(/«\s*(.+?)\s*»/g)].map((m) => norm(m[1]))
  const absentes = citations.filter((c) => !sources.includes(c) && !tests.includes(c))
  const parTest = citations.filter((c) => !sources.includes(c) && tests.includes(c)).length
  verifier(
    'Textes identiques à SPEC_UI (français)',
    absentes.map((c) => `« ${c} » introuvable`),
    `${citations.length} citations : ${citations.length - parTest} dans les textes et données, ${parTest} composées et vérifiées par test`,
  )
}

console.log('| Critère | État | Détail |\n|---|---|---|')
for (const r of resultats) console.log(`| ${r.critere} | ${r.ok ? '✅' : '❌'} | ${r.detail} |`)
process.exit(resultats.every((r) => r.ok) ? 0 : 1)

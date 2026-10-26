#!/usr/bin/env node
// Génère le thème Flutter et les variables CSS depuis design/tokens.json (source unique).
// Usage : node tools/gen_tokens.mjs           → écrit les fichiers
//         node tools/gen_tokens.mjs --check   → échoue si un fichier généré n'est pas à jour
import { readFileSync, writeFileSync, existsSync } from 'node:fs'
import { dirname, join, relative } from 'node:path'
import { fileURLToPath } from 'node:url'

const root = join(dirname(fileURLToPath(import.meta.url)), '..')
const tokens = JSON.parse(readFileSync(join(root, 'design/tokens.json'), 'utf8'))

const HEADER = 'GÉNÉRÉ par tools/gen_tokens.mjs depuis design/tokens.json — ne pas modifier à la main.'

// ---------- utilitaires ----------

// Ignore les clés de commentaire (« _note », « _rule »…).
const entries = (obj) => Object.entries(obj).filter(([k]) => !k.startsWith('_'))
const cap = (s) => s[0].toUpperCase() + s.slice(1)
const kebab = (s) => s.replace(/([a-z0-9])([A-Z])/g, '$1-$2').toLowerCase()
const num = (n) => (Number.isInteger(n) ? `${n}.0` : `${n}`)

// '#6C809A' ou 'rgba(192,57,43,.12)' → 'Color(0xFF6C809A)'
function dartColor(css) {
  const hex = css.match(/^#([0-9a-f]{6})$/i)
  if (hex) return `Color(0xFF${hex[1].toUpperCase()})`
  const rgba = css.match(/^rgba\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*([\d.]+)\s*\)$/i)
  if (rgba) {
    const [r, g, b] = rgba.slice(1, 4).map(Number)
    const a = Math.round(Number(rgba[4]) * 255)
    const h = (v) => v.toString(16).padStart(2, '0').toUpperCase()
    return `Color(0x${h(a)}${h(r)}${h(g)}${h(b)})`
  }
  throw new Error(`Couleur non reconnue : ${css}`)
}

// '0 6px 16px rgba(192,57,43,.35)' → BoxShadow Dart
function dartShadow(css) {
  const m = css.match(/^(-?[\d.]+)(?:px)?\s+(-?[\d.]+)(?:px)?\s+([\d.]+)(?:px)?\s+(rgba\(.+\))$/)
  if (!m) throw new Error(`Ombre non reconnue : ${css}`)
  return `BoxShadow(offset: Offset(${num(+m[1])}, ${num(+m[2])}), blurRadius: ${num(+m[3])}, color: ${dartColor(m[4])})`
}

const isShadow = (key) => key.endsWith('Shadow')

// ---------- collecte des couleurs ----------

// Liste plate { group, name, value, usage } ; les ombres sont traitées à part.
const colors = []
const shadows = []
for (const [group, values] of entries(tokens.color)) {
  for (const [key, def] of entries(values)) {
    if (typeof def === 'string') {
      if (isShadow(key)) shadows.push({ name: key.replace(/Shadow$/, ''), value: def })
      else colors.push({ group, name: key, value: def })
    } else if ('value' in def) {
      colors.push({ group, name: key, value: def.value, usage: def.usage })
    } else {
      // Statuts : { bg, fg, label }
      for (const [part, v] of Object.entries(def)) {
        if (part !== 'label') colors.push({ group, name: `${key}${cap(part)}`, value: v })
      }
    }
  }
}

// Nom Dart / CSS : les couleurs de marque gardent leur nom, les autres sont préfixées par leur groupe.
const colorId = (c) => (c.group === 'brand' ? c.name : `${c.group}${cap(c.name)}`)

// ---------- Dart : couleurs et ombres ----------

function genDartColors() {
  const lines = [`// ${HEADER}`, '', "import 'package:flutter/painting.dart';", '', '/// Couleurs Hydrotic CI.', 'abstract final class HydroticColors {']
  let group = null
  for (const c of colors) {
    if (c.group !== group) {
      if (group) lines.push('')
      lines.push(`  // ${c.group}`)
      group = c.group
    }
    if (c.usage) lines.push(`  /// ${c.usage}`)
    lines.push(`  static const Color ${colorId(c)} = ${dartColor(c.value)};`)
  }
  lines.push('}', '', '/// Ombres Hydrotic CI.', 'abstract final class HydroticShadows {')
  for (const s of shadows) lines.push(`  static const List<BoxShadow> ${s.name} = [${dartShadow(s.value)}];`)
  lines.push('}', '')
  return lines.join('\n')
}

// ---------- Dart : typographie mobile ----------

function dartTextStyle({ size, weight, lineHeight, letterSpacing }, family) {
  const parts = [`fontFamily: ${family}`, `fontSize: ${num(size)}`, `fontWeight: FontWeight.w${weight}`]
  if (lineHeight) parts.push(`height: ${num(lineHeight)}`)
  if (letterSpacing) parts.push(`letterSpacing: ${num(letterSpacing)}`)
  return `TextStyle(${parts.join(', ')})`
}

function genDartText() {
  const t = tokens.typography
  const lines = [
    `// ${HEADER}`, '', "import 'package:flutter/painting.dart';", '',
    '/// Styles de texte Hydrotic CI (application mobile).',
    'abstract final class HydroticText {',
    `  static const String fontFamily = '${t.fontFamily}';`, '',
  ]
  for (const [name, def] of entries(t.mobile)) {
    if (def.transform === 'uppercase') lines.push('  /// À afficher en MAJUSCULES (`toUpperCase()`).')
    lines.push(`  static const TextStyle ${name} = ${dartTextStyle(def, 'fontFamily')};`)
    if (def.activeWeight) {
      lines.push(`  static const TextStyle ${name}Active = ${dartTextStyle({ ...def, weight: def.activeWeight }, 'fontFamily')};`)
    }
  }
  lines.push('}', '')
  return lines.join('\n')
}

// ---------- Dart : rayons, espacements, tailles ----------

function dartDoubles(className, doc, obj) {
  const lines = [`/// ${doc}`, `abstract final class ${className} {`]
  for (const [name, v] of entries(obj)) {
    if (typeof v === 'number') lines.push(`  static const double ${name} = ${num(v)};`)
    else {
      for (const [k, sub] of entries(v)) lines.push(`  static const double ${name}${cap(k)} = ${num(sub)};`)
    }
  }
  lines.push('}')
  return lines
}

function genDartSizes() {
  return [
    `// ${HEADER}`, '',
    ...dartDoubles('HydroticRadius', 'Rayons des coins.', tokens.radius), '',
    ...dartDoubles('HydroticSpacing', 'Espacements.', tokens.spacing), '',
    ...dartDoubles('HydroticSizes', 'Tailles fixes des composants.', tokens.size), '',
  ].join('\n')
}

// ---------- CSS ----------

function genCss() {
  const t = tokens.typography
  const lines = [`/* ${HEADER} */`, '', ':root {']
  lines.push('  /* Couleurs */')
  for (const c of colors) lines.push(`  --color-${kebab(colorId(c))}: ${c.value};`)
  lines.push('', '  /* Ombres */')
  for (const s of shadows) lines.push(`  --shadow-${kebab(s.name)}: ${s.value};`)
  lines.push('', '  /* Typographie */', `  --font-family: ${t.fontFamily}, ${t.fallback};`)
  for (const scope of ['mobile', 'dashboard']) {
    for (const [name, def] of entries(t[scope])) {
      const p = `--text-${scope === 'dashboard' ? 'dash' : 'mobile'}-${kebab(name)}`
      lines.push(`  ${p}-size: ${def.size}px;`, `  ${p}-weight: ${def.weight};`)
      if (def.activeWeight) lines.push(`  ${p}-active-weight: ${def.activeWeight};`)
      if (def.lineHeight) lines.push(`  ${p}-line-height: ${def.lineHeight};`)
      if (def.letterSpacing) lines.push(`  ${p}-letter-spacing: ${def.letterSpacing}px;`)
    }
  }
  const px = (prefix, obj) => {
    for (const [name, v] of entries(obj)) {
      if (typeof v === 'number') lines.push(`  --${prefix}-${kebab(name)}: ${v}px;`)
      else for (const [k, sub] of entries(v)) lines.push(`  --${prefix}-${kebab(name)}-${k}: ${sub}px;`)
    }
  }
  lines.push('', '  /* Rayons */'); px('radius', tokens.radius)
  lines.push('', '  /* Espacements */'); px('space', tokens.spacing)
  lines.push('', '  /* Tailles */'); px('size', tokens.size)
  lines.push('}', '')
  return lines.join('\n')
}

// ---------- écriture ----------

const outputs = {
  'mobile/lib/theme/hydrotic_colors.dart': genDartColors(),
  'mobile/lib/theme/hydrotic_text.dart': genDartText(),
  'mobile/lib/theme/hydrotic_sizes.dart': genDartSizes(),
  'dashboard/src/styles/tokens.css': genCss(),
}

const check = process.argv.includes('--check')
let stale = 0
for (const [path, content] of Object.entries(outputs)) {
  const file = join(root, path)
  if (check) {
    if (!existsSync(file) || readFileSync(file, 'utf8') !== content) {
      console.error(`Pas à jour : ${relative(root, file)}`)
      stale++
    }
  } else {
    writeFileSync(file, content)
    console.log(`Écrit : ${path}`)
  }
}
if (stale) {
  console.error('Lancez : node tools/gen_tokens.mjs')
  process.exit(1)
}

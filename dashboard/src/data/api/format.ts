// Mise en forme des données de l'API pour l'affichage (heure d'Abidjan = UTC).
import { NBSP } from '../mock/parse'

const FUSEAU = 'Africa/Abidjan'

const majuscule = (s: string) => s.charAt(0).toUpperCase() + s.slice(1)

/** « Mercredi 17 juin » */
export function jourLong(date: Date): string {
  return majuscule(
    new Intl.DateTimeFormat('fr-FR', { weekday: 'long', day: 'numeric', month: 'long', timeZone: FUSEAU }).format(date),
  )
}

/** « 18:42 » */
export function heure(date: Date): string {
  return new Intl.DateTimeFormat('fr-FR', { hour: '2-digit', minute: '2-digit', timeZone: FUSEAU }).format(date)
}

/** « Mercredi 17 juin · 18:42 » (format des alertes de la phase 1). */
export function dateAlerte(iso: string): string {
  const d = new Date(iso)
  return `${jourLong(d)} · ${heure(d)}`
}

/** Ancienneté courte : « 38 min », « 1 h », « 2 j ». */
export function depuis(iso: string, maintenant: Date = new Date()): string {
  const minutes = Math.max(0, Math.round((maintenant.getTime() - new Date(iso).getTime()) / 60000))
  if (minutes < 60) return `${minutes}${NBSP}min`
  if (minutes < 60 * 24) return `${Math.floor(minutes / 60)}${NBSP}h`
  return `${Math.floor(minutes / (60 * 24))}${NBSP}j`
}

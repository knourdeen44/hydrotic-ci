import { describe, expect, it } from 'vitest'
import { NBSP } from '../mock/parse'
import { dateAlerte, depuis, heure } from './format'

describe('mise en forme', () => {
  it('date des alertes comme en phase 1', () => {
    expect(dateAlerte('2026-06-17T18:42:00Z')).toBe('Mercredi 17 juin · 18:42')
  })
  it('heure d’Abidjan (UTC)', () => {
    expect(heure(new Date('2026-10-27T05:07:00Z'))).toBe('05:07')
  })
  it('ancienneté', () => {
    const maintenant = new Date('2026-10-27T12:00:00Z')
    expect(depuis('2026-10-27T11:22:00Z', maintenant)).toBe(`38${NBSP}min`)
    expect(depuis('2026-10-27T10:30:00Z', maintenant)).toBe(`1${NBSP}h`)
    expect(depuis('2026-10-25T12:00:00Z', maintenant)).toBe(`2${NBSP}j`)
  })
})

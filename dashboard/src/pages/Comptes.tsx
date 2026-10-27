import { useEffect, useState } from 'react'
import Bouton from '../components/Bouton'
import PageHeader from '../components/PageHeader'
import Panel from '../components/Panel'
import { repositories } from '../data'
import { ROLES, type Compte, type Role } from '../data/models'
import { fr } from '../i18n/fr'
import { useEtat } from '../state/etat'
import styles from './pages.module.css'

/** Administration : nommer les agents (ONPC, mairies) et leur service. */
export default function Comptes() {
  const [comptes, setComptes] = useState<Compte[]>()
  const [brouillons, setBrouillons] = useState<Record<string, { role: Role; service: string }>>({})
  const { toast } = useEtat()

  useEffect(() => {
    repositories.users.comptes().then(setComptes, () => toast(fr.erreurChargement))
  }, [toast])

  if (!comptes) return null
  const valeur = (c: Compte) => brouillons[c.id] ?? { role: c.role, service: c.service ?? '' }
  const modifier = (c: Compte, champ: Partial<{ role: Role; service: string }>) =>
    setBrouillons((b) => ({ ...b, [c.id]: { ...valeur(c), ...champ } }))
  const enregistrer = async (c: Compte) => {
    const v = valeur(c)
    try {
      await repositories.users.changerRole(c.id, v.role, v.service.trim() || null)
      setComptes(await repositories.users.comptes())
      toast(fr.enregistre)
    } catch (e) {
      toast(e instanceof Error ? e.message : fr.erreurChargement)
    }
  }

  return (
    <>
      <PageHeader titre={fr.comptes} />
      <Panel titre={fr.comptes}>
        <table>
          <thead>
            <tr>
              {fr.colonnesComptes.map((c) => (
                <th key={c}>{c}</th>
              ))}
            </tr>
          </thead>
          <tbody>
            {comptes.map((c) => (
              <tr key={c.id}>
                <td>{[c.prenom, c.nom].filter(Boolean).join(' ') || '—'}</td>
                <td>{c.email ?? c.id}</td>
                <td>
                  <select
                    className={styles.select}
                    aria-label={`${fr.colonnesComptes[2]} — ${c.email ?? c.id}`}
                    value={valeur(c).role}
                    onChange={(e) => modifier(c, { role: e.target.value as Role })}
                  >
                    {ROLES.map((r) => (
                      <option key={r} value={r}>
                        {fr.roles[r]}
                      </option>
                    ))}
                  </select>
                </td>
                <td>
                  <input
                    className={styles.select}
                    aria-label={`${fr.colonnesComptes[3]} — ${c.email ?? c.id}`}
                    value={valeur(c).service}
                    onChange={(e) => modifier(c, { service: e.target.value })}
                  />
                </td>
                <td>
                  <Bouton onClick={() => enregistrer(c)}>{fr.enregistrer}</Bouton>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </Panel>
    </>
  )
}

// Client de l'API Hydrotic (seul module du tableau de bord autorisé à appeler le réseau).

const BASE = import.meta.env.VITE_API_URL ?? ''

type Jeton = () => Promise<string | null>
let jeton: Jeton = async () => null

/** Fournisseur du jeton de session Clerk (branché par le composant de connexion). */
export function definirJeton(fournisseur: Jeton): void {
  jeton = fournisseur
}

export class ErreurApi extends Error {
  readonly statut: number

  constructor(statut: number, message: string) {
    super(message)
    this.statut = statut
  }
}

export async function api<T>(chemin: string, options: { methode?: string; corps?: unknown } = {}): Promise<T> {
  const t = await jeton()
  const reponse = await fetch(`${BASE}${chemin}`, {
    method: options.methode ?? 'GET',
    headers: {
      ...(t ? { Authorization: `Bearer ${t}` } : {}),
      ...(options.corps !== undefined ? { 'Content-Type': 'application/json' } : {}),
    },
    body: options.corps !== undefined ? JSON.stringify(options.corps) : undefined,
  })
  if (!reponse.ok) {
    let detail = reponse.statusText
    try {
      detail = (await reponse.json()).detail ?? detail
    } catch {
      // Corps non JSON : on garde le texte du statut.
    }
    throw new ErreurApi(reponse.status, String(detail))
  }
  return reponse.status === 204 ? (undefined as T) : ((await reponse.json()) as T)
}

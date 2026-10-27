import { SignIn, useAuth, useClerk } from '@clerk/clerk-react'
import { useEffect, useState, type ReactNode } from 'react'
import logo from '../assets/logo_hydrotic_full.png'
import { repositories } from '../data'
import { definirJeton } from '../data/api/client'
import type { Utilisateur } from '../data/models'
import { fr } from '../i18n/fr'
import { CompteContext } from '../state/compte'
import Bouton from './Bouton'
import styles from './Connexion.module.css'

/** Mode réel : connexion Clerk, puis accès réservé aux agents et administrateurs. */
export default function Connexion({ children }: { children: ReactNode }) {
  const { isLoaded, isSignedIn, getToken } = useAuth()
  const { signOut } = useClerk()
  const [moi, setMoi] = useState<Utilisateur | null>(null)
  const [erreur, setErreur] = useState<string>()

  useEffect(() => {
    definirJeton(() => getToken())
  }, [getToken])

  useEffect(() => {
    if (!isSignedIn) {
      setMoi(null)
      return
    }
    repositories.users.agent().then(setMoi, () => setErreur(fr.erreurChargement))
  }, [isSignedIn])

  const page = (contenu: ReactNode) => (
    <main className={styles.page}>
      <img src={logo} alt={fr.nomApp} width={120} />
      <p className={styles.sousTitre}>{fr.espaceAutorites}</p>
      {contenu}
    </main>
  )

  if (!isLoaded) return page(null)
  if (!isSignedIn)
    return page(
      <>
        <p className={styles.texte}>{fr.connexionSousTitre}</p>
        <SignIn routing="hash" />
      </>,
    )
  if (!moi) return page(<p className={styles.texte}>{erreur ?? '…'}</p>)
  if (moi.role === 'CITOYEN')
    return page(
      <section className={styles.carte} role="alert">
        <h1 className={styles.titre}>{fr.accesReserve}</h1>
        <p className={styles.texte}>{fr.accesReserveDetail(moi.email ?? moi.id)}</p>
        <Bouton onClick={() => signOut()}>{fr.seDeconnecter}</Bouton>
      </section>,
    )
  return (
    <CompteContext.Provider value={{ utilisateur: moi, seDeconnecter: () => void signOut() }}>
      {children}
    </CompteContext.Provider>
  )
}

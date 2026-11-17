import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
// Police Inter embarquée (aucun chargement réseau à l'exécution)
import '@fontsource/inter/400.css'
import '@fontsource/inter/600.css'
import '@fontsource/inter/700.css'
import '@fontsource/inter/800.css'
import './styles/tokens.css'
import './styles/global.css'
import { ClerkProvider } from '@clerk/clerk-react'
import { frFR } from '@clerk/localizations'
import App from './App.tsx'
import Connexion from './components/Connexion'
import { MODE } from './data/mode'

// Adresse du tableau de bord (/hydrotic-ci/dashboard/ sur GitHub Pages).
const ACCUEIL = new URL(import.meta.env.BASE_URL, window.location.origin).href

// Mode réel : connexion Clerk obligatoire avant l'accès au tableau de bord.
createRoot(document.getElementById('root')!).render(
  <StrictMode>
    {MODE === 'api' ? (
      <ClerkProvider
        publishableKey={import.meta.env.VITE_CLERK_PUBLISHABLE_KEY!}
        localization={frFR}
        // Sans ces adresses, Clerk renvoie vers la racine du domaine (404 sur GitHub Pages).
        signInFallbackRedirectUrl={ACCUEIL}
        signUpFallbackRedirectUrl={ACCUEIL}
        afterSignOutUrl={ACCUEIL}
      >
        <Connexion>
          <App />
        </Connexion>
      </ClerkProvider>
    ) : (
      <App />
    )}
  </StrictMode>,
)

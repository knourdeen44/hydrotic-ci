/// <reference types="vite/client" />

interface ImportMetaEnv {
  /** Adresse de l'API Hydrotic (mode réel). */
  readonly VITE_API_URL?: string
  /** Clé publiable Clerk (publique). */
  readonly VITE_CLERK_PUBLISHABLE_KEY?: string
  /** « demo » force les données fictives (tests, comparaison aux maquettes). */
  readonly VITE_DONNEES?: string
}

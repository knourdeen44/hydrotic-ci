import logo from './assets/logo_hydrotic_full.png'
import dashboard from './fixtures/dashboard.json'

// Page provisoire de l'étape 1 (initialisation) : remplacée par D1 à l'étape 6.
function App() {
  return (
    <main style={{ fontFamily: 'Inter, system-ui, sans-serif', padding: 26 }}>
      <img src={logo} alt="Hydrotic CI" width={160} />
      <h1>{dashboard.entete.titre}</h1>
      <p>Initialisation terminée — étape 1.</p>
    </main>
  )
}

export default App

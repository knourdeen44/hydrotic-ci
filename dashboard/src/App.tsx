import { HashRouter, Route, Routes } from 'react-router-dom'
import Layout from './components/Layout'
import Alertes from './pages/Alertes'
import Comptes from './pages/Comptes'
import Historique from './pages/Historique'
import Overview from './pages/Overview'
import Previsions from './pages/Previsions'
import Signalements from './pages/Signalements'
import SosVictimes from './pages/SosVictimes'
import Supervision from './pages/Supervision'
import ZonesSeuils from './pages/ZonesSeuils'
import ThemePreview from './pages/dev/ThemePreview'
import EtatProvider from './state/EtatProvider'

// Routage par fragment (#/alertes…) : fonctionne tel quel sur GitHub Pages, sans réécriture d'adresses.
// Chemins = identifiants du menu (`dashboard.json > menu`).
function App() {
  return (
    <EtatProvider>
      <HashRouter>
        <Routes>
          <Route element={<Layout />}>
            <Route index element={<Overview />} />
            <Route path="alertes" element={<Alertes />} />
            <Route path="sos" element={<SosVictimes />} />
            <Route path="signalements" element={<Signalements />} />
            <Route path="previsions" element={<Previsions />} />
            <Route path="historique" element={<Historique />} />
            <Route path="zones" element={<ZonesSeuils />} />
            <Route path="supervision" element={<Supervision />} />
            <Route path="comptes" element={<Comptes />} />
          </Route>
          <Route path="dev/theme" element={<ThemePreview />} />
        </Routes>
      </HashRouter>
    </EtatProvider>
  )
}

export default App

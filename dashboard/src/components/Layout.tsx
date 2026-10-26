import { Outlet } from 'react-router-dom'
import styles from './Layout.module.css'
import Sidebar from './Sidebar'

/** Structure commune : barre latérale de 230 px + zone principale (fond slateXLight). */
export default function Layout() {
  return (
    <div className={styles.app}>
      <Sidebar />
      <main className={styles.main}>
        <Outlet />
      </main>
    </div>
  )
}

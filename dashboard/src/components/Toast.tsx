import styles from './Toast.module.css'

/** Message bref en bas d'écran (ex. « Disponible dans une prochaine version »). */
export default function Toast({ message }: { message: string }) {
  return (
    <div className={styles.toast} role="status" aria-live="polite">
      {message}
    </div>
  )
}

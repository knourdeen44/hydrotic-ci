import type { ButtonHTMLAttributes } from 'react'
import ui from './ui.module.css'

/** Bouton principal du tableau de bord (prototype : `.btn`, rayon 10). */
export default function Bouton({ className, ...props }: ButtonHTMLAttributes<HTMLButtonElement>) {
  return <button type="button" className={`${ui.btn} ${className ?? ''}`} {...props} />
}

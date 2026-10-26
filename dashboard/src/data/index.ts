import { createMockRepositories } from './mock/mockRepositories'
import type { Repositories } from './repositories'

// Point de branchement unique des dépôts : en phase 2, remplacer par les dépôts API ici.
export const repositories: Repositories = createMockRepositories()

export type * from './models'
export type * from './repositories'

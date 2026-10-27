import { createApiRepositories } from './api/apiRepositories'
import { createMockRepositories } from './mock/mockRepositories'
import { MODE } from './mode'
import type { Repositories } from './repositories'

// Point de branchement unique des dépôts : API en mode réel, fixtures en mode démonstration.
export const repositories: Repositories = MODE === 'api' ? createApiRepositories() : createMockRepositories()

export type * from './models'
export type * from './repositories'

import { Injectable } from "@nestjs/common"
import type { ExtensionsService } from "../extensions/extensions.service"
import type { TrunksService } from "../trunks/trunks.service"
import type { QueuesService } from "../queues/queues.service"
import type { CdrService } from "../cdr/cdr.service"

@Injectable()
export class DashboardService {
  constructor(
    private extensionsService: ExtensionsService,
    private trunksService: TrunksService,
    private queuesService: QueuesService,
    private cdrService: CdrService,
  ) {}

  /**
   * Retorna estatísticas do dashboard
   */
  async getStats(tenantId: number) {
    const extensions = await this.extensionsService.findAll(tenantId)
    const trunks = await this.trunksService.findAll(tenantId)
    const queues = await this.queuesService.findAll(tenantId)
    const cdrStats = await this.cdrService.getStats(tenantId, "hoje")

    return {
      ramais: {
        total: extensions.length,
        online: extensions.filter((e) => e.online).length,
        offline: extensions.filter((e) => !e.online).length,
      },
      troncos: {
        total: trunks.length,
        online: trunks.filter((t) => t.online).length,
        offline: trunks.filter((t) => !t.online).length,
      },
      filas: {
        total: queues.length,
      },
      chamadas: cdrStats,
    }
  }

  /**
   * Retorna chamadas recentes
   */
  async getRecentCalls(tenantId: number, limit = 10) {
    return this.cdrService.findAll(tenantId, { limit })
  }
}

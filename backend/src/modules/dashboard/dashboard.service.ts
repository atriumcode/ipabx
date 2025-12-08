import { Injectable } from "@nestjs/common"
import type { Repository } from "typeorm"
import type { Extension } from "../extensions/entities/extension.entity"
import type { Trunk } from "../trunks/entities/trunk.entity"
import type { Queue } from "../queues/entities/queue.entity"
import type { Cdr } from "../cdr/entities/cdr.entity"

@Injectable()
export class DashboardService {
  constructor(
    private extensionRepository: Repository<Extension>,
    private trunkRepository: Repository<Trunk>,
    private queueRepository: Repository<Queue>,
    private cdrRepository: Repository<Cdr>,
  ) {}

  /**
   * Retorna estatísticas do dashboard
   */
  async getStats(tenantId: number) {
    const [totalExtensions, extensionsOnline, totalTrunks, trunksOnline, totalQueues, totalCalls] = await Promise.all([
      this.extensionRepository.count({ where: { tenantId, ativo: true } }),
      this.extensionRepository.count({ where: { tenantId, online: true } }),
      this.trunkRepository.count({ where: { tenantId, ativo: true } }),
      this.trunkRepository.count({ where: { tenantId, online: true } }),
      this.queueRepository.count({ where: { tenantId, ativo: true } }),
      this.cdrRepository.count({ where: { tenantId } }),
    ])

    return {
      ramais: {
        total: totalExtensions,
        online: extensionsOnline,
        offline: totalExtensions - extensionsOnline,
      },
      troncos: {
        total: totalTrunks,
        online: trunksOnline,
        offline: totalTrunks - trunksOnline,
      },
      filas: {
        total: totalQueues,
      },
      chamadas: {
        total: totalCalls,
      },
    }
  }

  /**
   * Retorna chamadas recentes
   */
  async getRecentCalls(tenantId: number, limit = 10) {
    return this.cdrRepository.find({
      where: { tenantId },
      order: { dataHora: "DESC" },
      take: limit,
    })
  }
}

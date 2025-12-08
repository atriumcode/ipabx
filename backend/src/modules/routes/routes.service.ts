import { Injectable } from "@nestjs/common"
import type { Repository } from "typeorm"
import type { InboundRoute } from "./entities/inbound-route.entity"
import type { OutboundRoute } from "./entities/outbound-route.entity"

@Injectable()
export class RoutesService {
  constructor(
    private inboundRouteRepository: Repository<InboundRoute>,
    private outboundRouteRepository: Repository<OutboundRoute>,
  ) {}

  async findAllInbound(tenantId: number) {
    return await this.inboundRouteRepository.find({
      where: { tenantId },
      order: { prioridade: "ASC" },
    })
  }

  async findAllOutbound(tenantId: number) {
    return await this.outboundRouteRepository.find({
      where: { tenantId },
      order: { prioridade: "ASC" },
    })
  }

  async createInbound(data: Partial<InboundRoute>) {
    const route = this.inboundRouteRepository.create(data)
    return await this.inboundRouteRepository.save(route)
  }

  async createOutbound(data: Partial<OutboundRoute>) {
    const route = this.outboundRouteRepository.create(data)
    return await this.outboundRouteRepository.save(route)
  }

  async updateInbound(id: number, data: Partial<InboundRoute>) {
    await this.inboundRouteRepository.update(id, data)
    return await this.inboundRouteRepository.findOne({ where: { id } })
  }

  async updateOutbound(id: number, data: Partial<OutboundRoute>) {
    await this.outboundRouteRepository.update(id, data)
    return await this.outboundRouteRepository.findOne({ where: { id } })
  }

  async removeInbound(id: number) {
    await this.inboundRouteRepository.delete(id)
    return { message: "Rota de entrada removida com sucesso" }
  }

  async removeOutbound(id: number) {
    await this.outboundRouteRepository.delete(id)
    return { message: "Rota de saída removida com sucesso" }
  }
}

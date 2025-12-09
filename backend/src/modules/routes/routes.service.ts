import { Injectable } from "@nestjs/common"
import { InjectRepository } from "@nestjs/typeorm"
import { Repository } from "typeorm"
import { InboundRoute } from "./entities/inbound-route.entity"
import { OutboundRoute } from "./entities/outbound-route.entity"

@Injectable()
export class RoutesService {
  constructor(
    @InjectRepository(InboundRoute)
    private readonly inboundRouteRepository: Repository<InboundRoute>,
    @InjectRepository(OutboundRoute)
    private readonly outboundRouteRepository: Repository<OutboundRoute>,
  ) {}

  async findAllInbound(tenantId: number) {
    return this.inboundRouteRepository.find({
      where: { tenantId },
      order: { prioridade: "ASC" },
    })
  }

  async findAllOutbound(tenantId: number) {
    return this.outboundRouteRepository.find({
      where: { tenantId },
      order: { prioridade: "ASC" },
    })
  }

  async createInbound(data: Partial<InboundRoute>) {
    const route = this.inboundRouteRepository.create(data)
    return this.inboundRouteRepository.save(route)
  }

  async createOutbound(data: Partial<OutboundRoute>) {
    const route = this.outboundRouteRepository.create(data)
    return this.outboundRouteRepository.save(route)
  }

  async updateInbound(id: number, data: Partial<InboundRoute>) {
    await this.inboundRouteRepository.update(id, data)
    return this.inboundRouteRepository.findOne({ where: { id } })
  }

  async updateOutbound(id: number, data: Partial<OutboundRoute>) {
    await this.outboundRouteRepository.update(id, data)
    return this.outboundRouteRepository.findOne({ where: { id } })
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

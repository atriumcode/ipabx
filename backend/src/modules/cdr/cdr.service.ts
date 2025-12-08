import { Injectable } from "@nestjs/common"
import type { Repository } from "typeorm"
import type { Cdr } from "./entities/cdr.entity"

@Injectable()
export class CdrService {
  constructor(private cdrRepository: Repository<Cdr>) {}

  async findAll(tenantId: number, filters?: any) {
    const query = this.cdrRepository
      .createQueryBuilder("cdr")
      .where("cdr.tenantId = :tenantId", { tenantId })
      .orderBy("cdr.dataHora", "DESC")

    if (filters?.dataInicio) {
      query.andWhere("cdr.dataHora >= :dataInicio", { dataInicio: filters.dataInicio })
    }

    if (filters?.dataFim) {
      query.andWhere("cdr.dataHora <= :dataFim", { dataFim: filters.dataFim })
    }

    return await query.take(filters?.limit || 100).getMany()
  }

  async findOne(id: number, tenantId: number) {
    return await this.cdrRepository.findOne({
      where: { id, tenantId },
    })
  }

  async getStats(tenantId: number, periodo = "hoje") {
    const query = this.cdrRepository.createQueryBuilder("cdr").where("cdr.tenantId = :tenantId", { tenantId })

    if (periodo === "hoje") {
      query.andWhere("DATE(cdr.dataHora) = CURRENT_DATE")
    }

    const [totalChamadas, data] = await Promise.all([
      query.getCount(),
      query
        .select([
          "COUNT(*) as total",
          "SUM(CASE WHEN cdr.disposicao = 'ANSWERED' THEN 1 ELSE 0 END) as atendidas",
          "SUM(CASE WHEN cdr.disposicao IN ('BUSY', 'NO ANSWER') THEN 1 ELSE 0 END) as perdidas",
          "AVG(cdr.duracao) as duracaoMedia",
        ])
        .getRawOne(),
    ])

    return {
      totalChamadas,
      atendidas: Number.parseInt(data.atendidas || 0),
      perdidas: Number.parseInt(data.perdidas || 0),
      duracaoMedia: Number.parseFloat(data.duracaoMedia || 0),
    }
  }
}

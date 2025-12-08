import { Injectable } from "@nestjs/common"
import type { Repository } from "typeorm"
import type { Ivr } from "./entities/ivr.entity"
import type { IvrOption } from "./entities/ivr-option.entity"

@Injectable()
export class IvrService {
  constructor(
    private ivrRepository: Repository<Ivr>,
    private ivrOptionRepository: Repository<IvrOption>,
  ) {}

  async findAll(tenantId: number) {
    return await this.ivrRepository.find({
      where: { tenantId },
      relations: ["opcoes"],
    })
  }

  async findOne(id: number, tenantId: number) {
    return await this.ivrRepository.findOne({
      where: { id, tenantId },
      relations: ["opcoes"],
    })
  }

  async create(data: Partial<Ivr>) {
    const ivr = this.ivrRepository.create(data)
    return await this.ivrRepository.save(ivr)
  }

  async update(id: number, data: Partial<Ivr>) {
    await this.ivrRepository.update(id, data)
    return await this.ivrRepository.findOne({
      where: { id },
      relations: ["opcoes"],
    })
  }

  async remove(id: number) {
    await this.ivrRepository.delete(id)
    return { message: "URA removida com sucesso" }
  }
}

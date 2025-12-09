import { Injectable } from "@nestjs/common"
import { InjectRepository } from "@nestjs/typeorm"
import { Repository } from "typeorm"
import { Ivr } from "./entities/ivr.entity"
import { IvrOption } from "./entities/ivr-option.entity"

@Injectable()
export class IvrService {
  constructor(
    @InjectRepository(Ivr)
    private readonly ivrRepository: Repository<Ivr>,
    @InjectRepository(IvrOption)
    private readonly ivrOptionRepository: Repository<IvrOption>,
  ) {}

  async findAll(tenantId: number) {
    return this.ivrRepository.find({
      where: { tenantId },
      relations: ["opcoes"],
    })
  }

  async findOne(id: number, tenantId: number) {
    return this.ivrRepository.findOne({
      where: { id, tenantId },
      relations: ["opcoes"],
    })
  }

  async create(data: Partial<Ivr>) {
    const ivr = this.ivrRepository.create(data)
    return this.ivrRepository.save(ivr)
  }

  async update(id: number, data: Partial<Ivr>) {
    await this.ivrRepository.update(id, data)
    return this.ivrRepository.findOne({
      where: { id },
      relations: ["opcoes"],
    })
  }

  async remove(id: number) {
    await this.ivrRepository.delete(id)
    return { message: "URA removida com sucesso" }
  }
}

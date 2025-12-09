import { Injectable } from "@nestjs/common"
import { InjectRepository } from "@nestjs/typeorm"
import { Repository } from "typeorm"
import { Recording } from "./entities/recording.entity"

@Injectable()
export class RecordingsService {
  constructor(
    @InjectRepository(Recording)
    private readonly recordingRepository: Repository<Recording>,
  ) {}

  async findAll(tenantId: number) {
    return this.recordingRepository.find({
      where: { tenantId },
      order: { dataCriacao: "DESC" },
    })
  }

  async findOne(id: number, tenantId: number) {
    return this.recordingRepository.findOne({
      where: { id, tenantId },
    })
  }

  async remove(id: number) {
    await this.recordingRepository.delete(id)
    return { message: "Gravação removida com sucesso" }
  }
}

import { Injectable } from "@nestjs/common"
import type { Repository } from "typeorm"
import type { Recording } from "./entities/recording.entity"

@Injectable()
export class RecordingsService {
  private recordingRepository: Repository<Recording>

  constructor(recordingRepository: Repository<Recording>) {
    this.recordingRepository = recordingRepository
  }

  async findAll(tenantId: number) {
    return await this.recordingRepository.find({
      where: { tenantId },
      order: { dataCriacao: "DESC" },
    })
  }

  async findOne(id: number, tenantId: number) {
    return await this.recordingRepository.findOne({
      where: { id, tenantId },
    })
  }

  async remove(id: number) {
    await this.recordingRepository.delete(id)
    return { message: "Gravação removida com sucesso" }
  }
}

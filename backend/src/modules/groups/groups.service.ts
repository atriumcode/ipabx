import { Injectable } from "@nestjs/common"
import type { Repository } from "typeorm"
import type { Group } from "./entities/group.entity"

@Injectable()
export class GroupsService {
  private groupRepository: Repository<Group>

  constructor(groupRepository: Repository<Group>) {
    this.groupRepository = groupRepository
  }

  async findAll(tenantId: number) {
    return await this.groupRepository.find({
      where: { tenantId },
      relations: ["membros"],
    })
  }

  async findOne(id: number, tenantId: number) {
    return await this.groupRepository.findOne({
      where: { id, tenantId },
      relations: ["membros"],
    })
  }

  async create(data: Partial<Group>) {
    const group = this.groupRepository.create(data)
    return await this.groupRepository.save(group)
  }

  async update(id: number, data: Partial<Group>) {
    await this.groupRepository.update(id, data)
    return await this.groupRepository.findOne({ where: { id } })
  }

  async remove(id: number) {
    await this.groupRepository.delete(id)
    return { message: "Grupo removido com sucesso" }
  }
}

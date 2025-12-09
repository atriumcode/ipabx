import { Injectable } from "@nestjs/common"
import { InjectRepository } from "@nestjs/typeorm"
import { Repository } from "typeorm"
import { Group } from "./entities/group.entity"

@Injectable()
export class GroupsService {
  constructor(
    @InjectRepository(Group)
    private readonly groupRepository: Repository<Group>,
  ) {}

  async findAll(tenantId: number) {
    return this.groupRepository.find({
      where: { tenantId },
      relations: ["membros"],
    })
  }

  async findOne(id: number, tenantId: number) {
    return this.groupRepository.findOne({
      where: { id, tenantId },
      relations: ["membros"],
    })
  }

  async create(data: Partial<Group>) {
    const group = this.groupRepository.create(data)
    return this.groupRepository.save(group)
  }

  async update(id: number, data: Partial<Group>) {
    await this.groupRepository.update(id, data)
    return this.groupRepository.findOne({ where: { id } })
  }

  async remove(id: number) {
    await this.groupRepository.delete(id)
    return { message: "Grupo removido com sucesso" }
  }
}

import { Injectable, NotFoundException } from "@nestjs/common"
import type { Repository } from "typeorm"
import type { Queue } from "./entities/queue.entity"
import type { QueueMember } from "./entities/queue-member.entity"
import type { CreateQueueDto } from "./dto/create-queue.dto"
import type { UpdateQueueDto } from "./dto/update-queue.dto"

@Injectable()
export class QueuesService {
  constructor(
    private readonly queueRepository: Repository<Queue>,
    private readonly queueMemberRepository: Repository<QueueMember>,
  ) {}

  async create(createQueueDto: CreateQueueDto, tenantId: number): Promise<Queue> {
    const queue = this.queueRepository.create({
      ...createQueueDto,
      tenantId,
    })

    return this.queueRepository.save(queue)
  }

  async findAll(tenantId: number): Promise<Queue[]> {
    return this.queueRepository.find({
      where: { tenantId },
      relations: ["membros", "membros.extension"],
      order: { numero: "ASC" },
    })
  }

  async findOne(id: number, tenantId: number): Promise<Queue> {
    const queue = await this.queueRepository.findOne({
      where: { id, tenantId },
      relations: ["membros", "membros.extension"],
    })

    if (!queue) {
      throw new NotFoundException("Fila não encontrada")
    }

    return queue
  }

  async update(id: number, updateQueueDto: UpdateQueueDto, tenantId: number): Promise<Queue> {
    const queue = await this.findOne(id, tenantId)
    Object.assign(queue, updateQueueDto)
    return this.queueRepository.save(queue)
  }

  async remove(id: number, tenantId: number): Promise<void> {
    const queue = await this.findOne(id, tenantId)
    await this.queueRepository.remove(queue)
  }

  /**
   * Adiciona um membro à fila
   */
  async addMember(queueId: number, extensionId: number, tenantId: number, penalty = 0): Promise<QueueMember> {
    const member = this.queueMemberRepository.create({
      queueId,
      extensionId,
      tenantId,
      interface: `PJSIP/${extensionId}`,
      penalty,
    })

    return this.queueMemberRepository.save(member)
  }

  /**
   * Remove um membro da fila
   */
  async removeMember(memberId: number, tenantId: number): Promise<void> {
    const member = await this.queueMemberRepository.findOne({
      where: { id: memberId, tenantId },
    })

    if (!member) {
      throw new NotFoundException("Membro não encontrado")
    }

    await this.queueMemberRepository.remove(member)
  }
}

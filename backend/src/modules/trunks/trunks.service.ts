import { Injectable, NotFoundException, ConflictException } from "@nestjs/common"
import { InjectRepository } from "@nestjs/typeorm"
import type { Repository } from "typeorm"
import { Trunk } from "./entities/trunk.entity"
import type { CreateTrunkDto } from "./dto/create-trunk.dto"
import type { UpdateTrunkDto } from "./dto/update-trunk.dto"

@Injectable()
export class TrunksService {
  constructor(
    @InjectRepository(Trunk)
    private readonly trunkRepository: Repository<Trunk>,
  ) {}

  /**
   * Cria um novo tronco
   */
  async create(createTrunkDto: CreateTrunkDto, tenantId: number): Promise<Trunk> {
    const existing = await this.trunkRepository.findOne({
      where: { nome: createTrunkDto.nome, tenantId },
    })

    if (existing) {
      throw new ConflictException("Nome do tronco já existe")
    }

    const trunk = this.trunkRepository.create({
      ...createTrunkDto,
      tenantId,
    })

    return this.trunkRepository.save(trunk)
  }

  /**
   * Lista todos os troncos do tenant
   */
  async findAll(tenantId: number): Promise<Trunk[]> {
    return this.trunkRepository.find({
      where: { tenantId },
      order: { nome: "ASC" },
    })
  }

  /**
   * Busca tronco por ID
   */
  async findOne(id: number, tenantId: number): Promise<Trunk> {
    const trunk = await this.trunkRepository.findOne({
      where: { id, tenantId },
    })

    if (!trunk) {
      throw new NotFoundException("Tronco não encontrado")
    }

    return trunk
  }

  /**
   * Atualiza tronco
   */
  async update(id: number, updateTrunkDto: UpdateTrunkDto, tenantId: number): Promise<Trunk> {
    const trunk = await this.findOne(id, tenantId)

    Object.assign(trunk, updateTrunkDto)

    return this.trunkRepository.save(trunk)
  }

  /**
   * Remove tronco
   */
  async remove(id: number, tenantId: number): Promise<void> {
    const trunk = await this.findOne(id, tenantId)
    await this.trunkRepository.remove(trunk)
  }
}

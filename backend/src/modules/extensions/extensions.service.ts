import { Injectable, NotFoundException, ConflictException } from "@nestjs/common"
import type { Repository } from "typeorm"
import type { Extension } from "./entities/extension.entity"
import type { CreateExtensionDto } from "./dto/create-extension.dto"
import type { UpdateExtensionDto } from "./dto/update-extension.dto"

@Injectable()
export class ExtensionsService {
  constructor(private readonly extensionRepository: Repository<Extension>) {}

  /**
   * Cria um novo ramal
   */
  async create(createExtensionDto: CreateExtensionDto, tenantId: number): Promise<Extension> {
    // Verifica se o número já existe para este tenant
    const existing = await this.extensionRepository.findOne({
      where: { numero: createExtensionDto.numero, tenantId },
    })

    if (existing) {
      throw new ConflictException("Número de ramal já existe")
    }

    const extension = this.extensionRepository.create({
      ...createExtensionDto,
      tenantId,
    })

    const saved = await this.extensionRepository.save(extension)

    // TODO: Aqui deve criar os registros no Asterisk Realtime (ps_endpoints, ps_auths, ps_aors)
    await this.syncToAsterisk(saved)

    return saved
  }

  /**
   * Lista todos os ramais de um tenant
   */
  async findAll(tenantId: number): Promise<Extension[]> {
    return this.extensionRepository.find({
      where: { tenantId },
      order: { numero: "ASC" },
    })
  }

  /**
   * Busca um ramal por ID
   */
  async findOne(id: number, tenantId: number): Promise<Extension> {
    const extension = await this.extensionRepository.findOne({
      where: { id, tenantId },
    })

    if (!extension) {
      throw new NotFoundException("Ramal não encontrado")
    }

    return extension
  }

  /**
   * Atualiza um ramal
   */
  async update(id: number, updateExtensionDto: UpdateExtensionDto, tenantId: number): Promise<Extension> {
    const extension = await this.findOne(id, tenantId)
    Object.assign(extension, updateExtensionDto)
    const updated = await this.extensionRepository.save(extension)

    // Sincroniza com Asterisk
    await this.syncToAsterisk(updated)

    return updated
  }

  /**
   * Remove um ramal
   */
  async remove(id: number, tenantId: number): Promise<void> {
    const extension = await this.findOne(id, tenantId)

    // TODO: Remover do Asterisk Realtime
    await this.removeFromAsterisk(extension)

    await this.extensionRepository.remove(extension)
  }

  /**
   * Sincroniza ramal com Asterisk Realtime
   */
  private async syncToAsterisk(extension: Extension): Promise<void> {
    // Implementação será feita no módulo Asterisk
    console.log(`[Extensions] Sincronizando ramal ${extension.numero} com Asterisk`)
  }

  /**
   * Remove ramal do Asterisk Realtime
   */
  private async removeFromAsterisk(extension: Extension): Promise<void> {
    console.log(`[Extensions] Removendo ramal ${extension.numero} do Asterisk`)
  }
}

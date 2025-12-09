import { Injectable, NotFoundException } from "@nestjs/common"
import type { Repository } from "typeorm"
import type { Tenant } from "./entities/tenant.entity"
import type { CreateTenantDto } from "./dto/create-tenant.dto"
import type { UpdateTenantDto } from "./dto/update-tenant.dto"

@Injectable()
export class TenantsService {
  private readonly tenantRepository: Repository<Tenant>

  constructor(tenantRepository: Repository<Tenant>) {
    this.tenantRepository = tenantRepository
  }

  /**
   * Cria um novo tenant
   */
  async create(createTenantDto: CreateTenantDto): Promise<Tenant> {
    const tenant = this.tenantRepository.create(createTenantDto)
    return this.tenantRepository.save(tenant)
  }

  /**
   * Lista todos os tenants
   */
  async findAll(): Promise<Tenant[]> {
    return this.tenantRepository.find({
      order: { nome: "ASC" },
    })
  }

  /**
   * Busca um tenant por ID
   */
  async findOne(id: number): Promise<Tenant> {
    const tenant = await this.tenantRepository.findOne({ where: { id } })

    if (!tenant) {
      throw new NotFoundException("Tenant não encontrado")
    }

    return tenant
  }

  /**
   * Atualiza um tenant
   */
  async update(id: number, updateTenantDto: UpdateTenantDto): Promise<Tenant> {
    const tenant = await this.findOne(id)
    Object.assign(tenant, updateTenantDto)
    return this.tenantRepository.save(tenant)
  }

  /**
   * Remove um tenant
   */
  async remove(id: number): Promise<void> {
    const tenant = await this.findOne(id)
    await this.tenantRepository.remove(tenant)
  }
}

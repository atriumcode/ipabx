import { Injectable, NotFoundException } from "@nestjs/common"
import { InjectRepository } from "@nestjs/typeorm"
import { Repository } from "typeorm"
import { Tenant } from "./entities/tenant.entity"
import { CreateTenantDto } from "./dto/create-tenant.dto"
import { UpdateTenantDto } from "./dto/update-tenant.dto"

@Injectable()
export class TenantsService {
  constructor(
    @InjectRepository(Tenant)
    private readonly tenantRepository: Repository<Tenant>,
  ) {}

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

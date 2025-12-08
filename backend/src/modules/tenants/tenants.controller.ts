import { Controller, Get, Post, Patch, Param, Delete } from "@nestjs/common"
import type { TenantsService } from "./tenants.service"
import type { CreateTenantDto } from "./dto/create-tenant.dto"
import type { UpdateTenantDto } from "./dto/update-tenant.dto"

@Controller("tenants")
export class TenantsController {
  constructor(private readonly tenantsService: TenantsService) {}

  @Post()
  create(createTenantDto: CreateTenantDto) {
    return this.tenantsService.create(createTenantDto)
  }

  @Get()
  findAll() {
    return this.tenantsService.findAll()
  }

  @Get(":id")
  findOne(@Param("id") id: string) {
    return this.tenantsService.findOne(+id)
  }

  @Patch(":id")
  update(@Param("id") id: string, updateTenantDto: UpdateTenantDto) {
    return this.tenantsService.update(+id, updateTenantDto)
  }

  @Delete(":id")
  remove(@Param("id") id: string) {
    return this.tenantsService.remove(+id)
  }
}

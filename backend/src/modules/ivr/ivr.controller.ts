import { Controller, Get, Post, Body, Patch, Param, Delete, Query, UseGuards } from "@nestjs/common"
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard"
import type { IvrService } from "./ivr.service"
import type { Ivr } from "./entities/ivr.entity"

@Controller("ivr")
@UseGuards(JwtAuthGuard)
export class IvrController {
  constructor(private readonly ivrService: IvrService) {}

  @Get()
  findAll(@Query("tenantId") tenantId: string) {
    return this.ivrService.findAll(Number(tenantId))
  }

  @Get(":id")
  findOne(@Param("id") id: string, @Query("tenantId") tenantId: string) {
    return this.ivrService.findOne(Number(id), Number(tenantId))
  }

  @Post()
  create(@Body() data: Partial<Ivr>) {
    return this.ivrService.create(data)
  }

  @Patch(":id")
  update(@Param("id") id: string, @Body() data: Partial<Ivr>) {
    return this.ivrService.update(Number(id), data)
  }

  @Delete(":id")
  remove(@Param("id") id: string) {
    return this.ivrService.remove(Number(id))
  }
}

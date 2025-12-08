import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards } from "@nestjs/common"
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard"
import type { IvrService } from "./ivr.service"
import type { Ivr } from "./entities/ivr.entity"
import type { Request } from "express"

@Controller("ivr")
@UseGuards(JwtAuthGuard)
export class IvrController {
  constructor(private readonly ivrService: IvrService) {}

  @Get()
  findAll(req: Request) {
    return this.ivrService.findAll(req.user.tenantId)
  }

  @Get(":id")
  findOne(@Param('id') id: string, req: Request) {
    return this.ivrService.findOne(Number(id), req.user.tenantId)
  }

  @Post()
  create(@Body() data: Partial<Ivr>, req: Request) {
    return this.ivrService.create({ ...data, tenantId: req.user.tenantId })
  }

  @Patch(":id")
  update(@Param('id') id: string, @Body() data: Partial<Ivr>, req: Request) {
    return this.ivrService.update(Number(id), data)
  }

  @Delete(":id")
  remove(@Param('id') id: string, req: Request) {
    return this.ivrService.remove(Number(id))
  }
}

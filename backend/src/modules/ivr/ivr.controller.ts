import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards } from "@nestjs/common"
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard"
import type { IvrService } from "./ivr.service"
import type { Ivr } from "./entities/ivr.entity"

interface RequestWithUser {
  user: {
    id: number
    tenantId: number
    email: string
    perfil: string
  }
}

@Controller("ivr")
@UseGuards(JwtAuthGuard)
export class IvrController {
  constructor(private readonly ivrService: IvrService) {}

  @Get()
  findAll(req: RequestWithUser) {
    return this.ivrService.findAll(req.user.tenantId)
  }

  @Get(":id")
  findOne(@Param('id') id: string, req: RequestWithUser) {
    return this.ivrService.findOne(Number(id), req.user.tenantId)
  }

  @Post()
  create(@Body() data: Partial<Ivr>, req: RequestWithUser) {
    return this.ivrService.create({ ...data, tenantId: req.user.tenantId })
  }

  @Patch(":id")
  update(@Param('id') id: string, @Body() data: Partial<Ivr>, req: RequestWithUser) {
    return this.ivrService.update(Number(id), data)
  }

  @Delete(":id")
  remove(@Param('id') id: string, req: RequestWithUser) {
    return this.ivrService.remove(Number(id))
  }
}

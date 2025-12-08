import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Request } from "@nestjs/common"
import type { TrunksService } from "./trunks.service"
import type { CreateTrunkDto } from "./dto/create-trunk.dto"
import type { UpdateTrunkDto } from "./dto/update-trunk.dto"
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard"

@Controller("trunks")
@UseGuards(JwtAuthGuard)
export class TrunksController {
  constructor(private readonly trunksService: TrunksService) {}

  @Post()
  create(@Body() createTrunkDto: CreateTrunkDto, @Request() req) {
    return this.trunksService.create(createTrunkDto, req.user.tenantId)
  }

  @Get()
  findAll(@Request() req) {
    return this.trunksService.findAll(req.user.tenantId)
  }

  @Get(":id")
  findOne(@Param("id") id: string, @Request() req) {
    return this.trunksService.findOne(+id, req.user.tenantId)
  }

  @Patch(":id")
  update(@Param("id") id: string, @Body() updateTrunkDto: UpdateTrunkDto, @Request() req) {
    return this.trunksService.update(+id, updateTrunkDto, req.user.tenantId)
  }

  @Delete(":id")
  remove(@Param("id") id: string, @Request() req) {
    return this.trunksService.remove(+id, req.user.tenantId)
  }
}

import { Controller, Get, Post, Patch, Param, Delete, UseGuards, Request } from "@nestjs/common"
import type { ExtensionsService } from "./extensions.service"
import type { CreateExtensionDto } from "./dto/create-extension.dto"
import type { UpdateExtensionDto } from "./dto/update-extension.dto"
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard"

@Controller("extensions")
@UseGuards(JwtAuthGuard)
export class ExtensionsController {
  constructor(private readonly extensionsService: ExtensionsService) {}

  @Post()
  create(createExtensionDto: CreateExtensionDto, @Request() req) {
    return this.extensionsService.create(createExtensionDto, req.user.tenantId)
  }

  @Get()
  findAll(@Request() req) {
    return this.extensionsService.findAll(req.user.tenantId)
  }

  @Get(":id")
  findOne(@Param("id") id: string, @Request() req) {
    return this.extensionsService.findOne(+id, req.user.tenantId)
  }

  @Patch(":id")
  update(@Param("id") id: string, updateExtensionDto: UpdateExtensionDto, @Request() req) {
    return this.extensionsService.update(+id, updateExtensionDto, req.user.tenantId)
  }

  @Delete(":id")
  remove(@Param("id") id: string, @Request() req) {
    return this.extensionsService.remove(+id, req.user.tenantId)
  }
}

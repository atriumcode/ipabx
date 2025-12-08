import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards } from "@nestjs/common"
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard"
import type { RoutesService } from "./routes.service"
import type { InboundRoute } from "./entities/inbound-route.entity"
import type { OutboundRoute } from "./entities/outbound-route.entity"

@Controller("routes")
@UseGuards(JwtAuthGuard)
export class RoutesController {
  constructor(private readonly routesService: RoutesService) {}

  @Get("inbound")
  findAllInbound(tenantId: number) {
    return this.routesService.findAllInbound(tenantId)
  }

  @Get("outbound")
  findAllOutbound(tenantId: number) {
    return this.routesService.findAllOutbound(tenantId)
  }

  @Post("inbound")
  createInbound(@Body() data: Partial<InboundRoute>) {
    return this.routesService.createInbound(data)
  }

  @Post("outbound")
  createOutbound(@Body() data: Partial<OutboundRoute>) {
    return this.routesService.createOutbound(data)
  }

  @Patch("inbound/:id")
  updateInbound(@Param("id") id: string, @Body() data: Partial<InboundRoute>) {
    return this.routesService.updateInbound(+id, data)
  }

  @Patch("outbound/:id")
  updateOutbound(@Param("id") id: string, @Body() data: Partial<OutboundRoute>) {
    return this.routesService.updateOutbound(+id, data)
  }

  @Delete("inbound/:id")
  removeInbound(@Param("id") id: string) {
    return this.routesService.removeInbound(+id)
  }

  @Delete("outbound/:id")
  removeOutbound(@Param("id") id: string) {
    return this.routesService.removeOutbound(+id)
  }
}

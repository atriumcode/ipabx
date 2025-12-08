import { Controller, Get, Param, Query, UseGuards } from "@nestjs/common"
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard"
import type { CdrService } from "./cdr.service"

@Controller("cdr")
@UseGuards(JwtAuthGuard)
export class CdrController {
  constructor(private readonly cdrService: CdrService) {}

  @Get()
  findAll(@Query("tenantId") tenantId: number, @Query() filters: any) {
    return this.cdrService.findAll(tenantId, filters)
  }

  @Get("stats")
  getStats(@Query("tenantId") tenantId: number, @Query("periodo") periodo?: string) {
    return this.cdrService.getStats(tenantId, periodo)
  }

  @Get(":id")
  findOne(@Param("id") id: string, @Query("tenantId") tenantId: number) {
    return this.cdrService.findOne(+id, tenantId)
  }
}

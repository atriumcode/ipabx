import { Controller, Get, Param, Delete, Query, UseGuards } from "@nestjs/common"
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard"
import type { RecordingsService } from "./recordings.service"

@Controller("recordings")
@UseGuards(JwtAuthGuard)
export class RecordingsController {
  constructor(private readonly recordingsService: RecordingsService) {}

  @Get()
  findAll(@Query("tenantId") tenantId: string) {
    return this.recordingsService.findAll(Number(tenantId))
  }

  @Get(":id")
  findOne(@Param("id") id: string, @Query("tenantId") tenantId: string) {
    return this.recordingsService.findOne(Number(id), Number(tenantId))
  }

  @Delete(":id")
  remove(@Param("id") id: string) {
    return this.recordingsService.remove(+id)
  }
}

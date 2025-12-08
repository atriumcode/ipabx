import { Controller, Get, UseGuards, Req, Query } from "@nestjs/common"
import type { DashboardService } from "./dashboard.service"
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard"

@Controller("dashboard")
@UseGuards(JwtAuthGuard)
export class DashboardController {
  constructor(private readonly dashboardService: DashboardService) {}

  @Get("stats")
  getStats(@Req() req) {
    return this.dashboardService.getStats(req.user.tenantId)
  }

  @Get("recent-calls")
  getRecentCalls(@Req() req, @Query("limit") limit?: string) {
    return this.dashboardService.getRecentCalls(req.user.tenantId, limit ? +limit : 10)
  }
}

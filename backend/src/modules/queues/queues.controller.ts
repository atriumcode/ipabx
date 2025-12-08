import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Request } from "@nestjs/common"
import type { QueuesService } from "./queues.service"
import type { CreateQueueDto } from "./dto/create-queue.dto"
import type { UpdateQueueDto } from "./dto/update-queue.dto"
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard"

@Controller("queues")
@UseGuards(JwtAuthGuard)
export class QueuesController {
  constructor(private readonly queuesService: QueuesService) {}

  @Post()
  create(@Body() createQueueDto: CreateQueueDto, @Request() req) {
    return this.queuesService.create(createQueueDto, req.user.tenantId)
  }

  @Get()
  findAll(@Request() req) {
    return this.queuesService.findAll(req.user.tenantId)
  }

  @Get(":id")
  findOne(@Param("id") id: string, @Request() req) {
    return this.queuesService.findOne(+id, req.user.tenantId)
  }

  @Patch(":id")
  update(@Param("id") id: string, @Body() updateQueueDto: UpdateQueueDto, @Request() req) {
    return this.queuesService.update(+id, updateQueueDto, req.user.tenantId)
  }

  @Delete(":id")
  remove(@Param("id") id: string, @Request() req) {
    return this.queuesService.remove(+id, req.user.tenantId)
  }

  @Post(":id/members/:extensionId")
  addMember(@Param("id") id: string, @Param("extensionId") extensionId: string, @Request() req) {
    return this.queuesService.addMember(+id, +extensionId, req.user.tenantId)
  }

  @Delete("members/:memberId")
  removeMember(@Param("memberId") memberId: string, @Request() req) {
    return this.queuesService.removeMember(+memberId, req.user.tenantId)
  }
}

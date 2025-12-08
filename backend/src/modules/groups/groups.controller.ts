import { Controller, Get, Post, Body, Patch, Param, Delete, Query, UseGuards } from "@nestjs/common"
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard"
import type { GroupsService } from "./groups.service"
import type { Group } from "./entities/group.entity"

@Controller("groups")
@UseGuards(JwtAuthGuard)
export class GroupsController {
  constructor(private readonly groupsService: GroupsService) {}

  @Get()
  findAll(@Query('tenantId') tenantId: number) {
    return this.groupsService.findAll(tenantId);
  }

  @Get(":id")
  findOne(@Param('id') id: string, @Query('tenantId') tenantId: number) {
    return this.groupsService.findOne(Number(id), tenantId)
  }

  @Post()
  create(@Body() data: Partial<Group>) {
    return this.groupsService.create(data);
  }

  @Patch(":id")
  update(@Param('id') id: string, @Body() data: Partial<Group>) {
    return this.groupsService.update(Number(id), data)
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.groupsService.remove(Number(id));
  }
}

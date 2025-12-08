import { Controller, Get, Post, Patch, Param, Delete, UseGuards, Request } from "@nestjs/common"
import type { UsersService } from "./users.service"
import type { CreateUserDto } from "./dto/create-user.dto"
import type { UpdateUserDto } from "./dto/update-user.dto"
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard"

@Controller("users")
@UseGuards(JwtAuthGuard)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post()
  create(createUserDto: CreateUserDto, @Request() req) {
    return this.usersService.create(createUserDto, req.user.tenantId)
  }

  @Get()
  findAll(@Request() req) {
    return this.usersService.findAll(req.user.tenantId)
  }

  @Get(":id")
  findOne(@Param("id") id: string, @Request() req) {
    return this.usersService.findOne(+id, req.user.tenantId)
  }

  @Patch(":id")
  update(@Param("id") id: string, updateUserDto: UpdateUserDto, @Request() req) {
    return this.usersService.update(+id, updateUserDto, req.user.tenantId)
  }

  @Delete(":id")
  remove(@Param("id") id: string, @Request() req) {
    return this.usersService.remove(+id, req.user.tenantId)
  }
}

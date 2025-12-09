import { Controller, Post, UseGuards, Get, Request, Body } from "@nestjs/common"
import type { AuthService } from "./auth.service"
import type { LoginDto } from "./dto/login.dto"
import { JwtAuthGuard } from "./guards/jwt-auth.guard"

@Controller("auth")
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  /**
   * Endpoint de login
   */
  @Post("login")
  async login(@Body() loginDto: LoginDto) {
    return this.authService.login(loginDto)
  }

  /**
   * Verifica se o token é válido e retorna os dados do usuário
   */
  @Get("me")
  @UseGuards(JwtAuthGuard)
  async getProfile(@Request() req) {
    return {
      id: req.user.id,
      nome: req.user.nome,
      email: req.user.email,
      perfil: req.user.perfil,
      tenantId: req.user.tenantId,
      tenant: req.user.tenant,
    }
  }
}

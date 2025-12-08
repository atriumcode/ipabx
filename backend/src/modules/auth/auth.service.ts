import { Injectable, UnauthorizedException } from "@nestjs/common"
import type { JwtService } from "@nestjs/jwt"
import type { Repository } from "typeorm"
import * as bcrypt from "bcrypt"

import type { SystemUser } from "../users/entities/system-user.entity"
import type { LoginDto } from "./dto/login.dto"

@Injectable()
export class AuthService {
  private readonly userRepository: Repository<SystemUser>
  private readonly jwtService: JwtService

  constructor(userRepository: Repository<SystemUser>, jwtService: JwtService) {
    this.userRepository = userRepository
    this.jwtService = jwtService
  }

  /**
   * Valida as credenciais do usuário
   */
  async validateUser(email: string, senha: string): Promise<SystemUser | null> {
    const user = await this.userRepository.findOne({
      where: { email, ativo: true },
      relations: ["tenant"],
    })

    if (!user) {
      return null
    }

    const senhaValida = await bcrypt.compare(senha, user.senha)
    if (!senhaValida) {
      return null
    }

    return user
  }

  /**
   * Realiza o login e retorna o token JWT
   */
  async login(loginDto: LoginDto) {
    const user = await this.validateUser(loginDto.email, loginDto.senha)

    if (!user) {
      throw new UnauthorizedException("Credenciais inválidas")
    }

    // Atualiza último login
    await this.userRepository.update(user.id, {
      ultimoLogin: new Date(),
    })

    const payload = {
      sub: user.id,
      email: user.email,
      tenantId: user.tenantId,
      perfil: user.perfil,
    }

    return {
      accessToken: this.jwtService.sign(payload),
      user: {
        id: user.id,
        nome: user.nome,
        email: user.email,
        perfil: user.perfil,
        tenantId: user.tenantId,
        tenant: user.tenant,
      },
    }
  }

  /**
   * Valida o token JWT
   */
  async validateToken(token: string) {
    try {
      const decoded = this.jwtService.verify(token)
      const user = await this.userRepository.findOne({
        where: { id: decoded.sub, ativo: true },
        relations: ["tenant"],
      })
      return user
    } catch (error) {
      throw new UnauthorizedException("Token inválido")
    }
  }
}

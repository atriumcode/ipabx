import { Injectable, UnauthorizedException } from "@nestjs/common"
import { PassportStrategy } from "@nestjs/passport"
import { ExtractJwt, Strategy } from "passport-jwt"
import type { ConfigService } from "@nestjs/config"
import type { Repository } from "typeorm"
import type { SystemUser } from "../../users/entities/system-user.entity"

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  private userRepository: Repository<SystemUser>

  constructor(
    private configService: ConfigService,
    userRepository: Repository<SystemUser>,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: configService.get("JWT_SECRET"),
    })
    this.userRepository = userRepository
  }

  async validate(payload: any) {
    const user = await this.userRepository.findOne({
      where: { id: payload.sub, ativo: true },
      relations: ["tenant"],
    })

    if (!user) {
      throw new UnauthorizedException("Usuário não encontrado")
    }

    return user
  }
}

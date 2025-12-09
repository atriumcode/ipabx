import { Module } from "@nestjs/common"
import { JwtModule } from "@nestjs/jwt"
import { PassportModule } from "@nestjs/passport"
import { ConfigModule, ConfigService } from "@nestjs/config"
import { TypeOrmModule } from "@nestjs/typeorm"

import { AuthService } from "./auth.service"
import { AuthController } from "./auth.controller"
import { JwtStrategy } from "./strategies/jwt.strategy"
import { LocalStrategy } from "./strategies/local.strategy"
import { SystemUser } from "../users/entities/system-user.entity"

@Module({
  imports: [
    ConfigModule, // <-- ESSENCIAL! AGORA DISPONIBILIZA ConfigService

    TypeOrmModule.forFeature([SystemUser]),

    PassportModule.register({ defaultStrategy: "local" }),

    JwtModule.registerAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => ({
        secret: configService.get("JWT_SECRET"),
        signOptions: {
          expiresIn: configService.get("JWT_EXPIRES_IN", "24h"),
        },
      }),
      inject: [ConfigService],
    }),
  ],

  controllers: [AuthController],

  providers: [
    AuthService,
    LocalStrategy, // ordem não importa, mas precisa vir ANTES do export
    JwtStrategy,
  ],

  exports: [AuthService],
})
export class AuthModule {}

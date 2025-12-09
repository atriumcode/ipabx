import { Module } from "@nestjs/common"
import { ConfigModule, ConfigService } from "@nestjs/config"
import { AsteriskService } from "./asterisk.service"
import { AsteriskRealtimeService } from "./asterisk-realtime.service"

@Module({
  imports: [
    ConfigModule, // usa ConfigModule já carregado no AppModule
  ],
  providers: [
    AsteriskService,
    AsteriskRealtimeService,
    ConfigService, // garante injeção
  ],
  exports: [
    AsteriskService,
    AsteriskRealtimeService,
  ],
})
export class AsteriskModule {}

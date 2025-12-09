import { Module } from "@nestjs/common"
import { ConfigModule } from "@nestjs/config"
import { AsteriskService } from "./asterisk.service"
import { AsteriskRealtimeService } from "./asterisk-realtime.service"

@Module({
  imports: [
    ConfigModule, // garante que ConfigService está disponível para injeção
  ],
  providers: [
    AsteriskService,
    AsteriskRealtimeService,
  ],
  exports: [
    AsteriskService,
    AsteriskRealtimeService,
  ],
})
export class AsteriskModule {}

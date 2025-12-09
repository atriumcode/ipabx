import { Module } from "@nestjs/common"
import { ConfigModule, ConfigService } from "@nestjs/config"
import { AsteriskService } from "./asterisk.service"
import { AsteriskRealtimeService } from "./asterisk-realtime.service"

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
  ],
  providers: [
    AsteriskService,
    AsteriskRealtimeService,
    ConfigService, // ← Necessário!
  ],
  exports: [
    AsteriskService,
    AsteriskRealtimeService,
  ],
})
export class AsteriskModule {}
